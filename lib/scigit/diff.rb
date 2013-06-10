require 'diff-lcs'
require 'htmlentities'
require 'scigit'
require 'scigit/git'
require 'scigit/docstore'
require 'ydocx/differ'

module SciGit
  class Diff
    Block = Struct.new(:start_line, :type, :lines)
    FileDiff = Struct.new(:name, :new_name, :lines_changed, :binary, :blocks)

    def initialize
      @cur_change_id = 1
    end

    def add_blocks(type, lines, start, blocks)
      if type == '-' || type == '='
        blocks[0] << Block.new(start[0], type, lines)
        blocks[1] << nil unless type == '='
        start[0] += lines.length
      end
      if type == '+' || type == '='
        blocks[0] << nil unless type == '='
        blocks[1] << Block.new(start[1], type, lines)
        start[1] += lines.length
      end
    end

    def str_similarity(str1, str2)
      if str1.length + str2.length == 0
        return 1
      end
      l = ::Diff::LCS.lcs(str1, str2)
      return 2.0 * l.length / (str1.length + str2.length)
    end

    def get_detail_blocks(blocks1, blocks2, text_similarity, text_fn = lambda { |x| x })
      n = blocks1.length
      m = blocks2.length
      if n == 0 || m == 0
        return [[blocks1, blocks2]]
      end
      if n*m > 10000
        # assume it's all different QQ
        return [[blocks1, []], [[], blocks2]]
      end
      lcs = Array.new(n+1) { Array.new(m+1, 0) }
      action = Array.new(n+1) { Array.new(m+1, -1) }
      text1 = blocks1.map { |b| text_fn.call(b) }
      text2 = blocks2.map { |b| text_fn.call(b) }
        
      blocks1.reverse.each_with_index do |a, ii|
        blocks2.reverse.each_with_index do |b, jj|
          i = n-1-ii
          j = m-1-jj
          sim = (a.class == b.class ? text_similarity.call(text1[i], text2[j]) : 0)
          # printf "%d %d = %d\n", i, j, sim
          lcs[i][j] = lcs[i+1][j]
          action[i][j] = 0
          if lcs[i][j+1] > lcs[i][j]
            lcs[i][j] = lcs[i][j+1]
            action[i][j] = 1
          end
          if sim >= 0.5 && lcs[i+1][j+1] + sim > lcs[i][j]
            lcs[i][j] = lcs[i+1][j+1] + sim
            action[i][j] = 2
          end
        end
      end
      
      i = 0
      j = 0
      lblocks = []
      rblocks = []
      diff_blocks = []
      while i < n || j < m        
        if j == m || action[i][j] == 0
          lblocks << blocks1[i]
          i += 1
        elsif i == n || action[i][j] == 1
          rblocks << blocks2[j]
          j += 1
        else
          unless lblocks.empty? && rblocks.empty?
            if lblocks.empty? || rblocks.empty?
              diff_blocks << [lblocks.dup, rblocks.dup]
            else
              diff_blocks << [lblocks.dup, []]
              diff_blocks << [[], rblocks.dup]
            end
            lblocks = []
            rblocks = []
          end
          diff_blocks << [[blocks1[i]], [blocks2[j]]]
          i += 1
          j += 1
        end
      end
      unless lblocks.empty? && rblocks.empty?
        if lblocks.empty? || rblocks.empty?
          diff_blocks << [lblocks.dup, rblocks.dup]
        else
          diff_blocks << [lblocks.dup, []]
          diff_blocks << [[], rblocks.dup]
        end
      end
      diff_blocks
    end

    def get_diff_change_array(list1, list2)
      change_id = [Array.new(list1.length), Array.new(list2.length)]
      ::Diff::LCS.diff(list1, list2).each do |diff|
        count = diff.map { |c| c.action }.uniq.length
        if count == 1
          cid = -1
        else
          cid = @cur_change_id
          @cur_change_id += 1
        end
        diff.each do |change|
          change_id[change.action == '-' ? 0 : 1][change.position] = cid
        end
      end
      change_id
    end

    def generate_side_blocks(blocks)
      ret = [[], []]
      # Try to split up remove/add blocks
      i = 0
      while i < blocks[0].length
        ba = blocks[0][i]
        bb = blocks[1][i+1]
        if !ba.nil? && ba.type == '-' && !bb.nil? && bb.type == '+'
          old_start = ba.start_line
          new_start = bb.start_line
          get_detail_blocks(ba.lines, bb.lines, method(:str_similarity)).each do |block|
            if block[1].empty?
              ret[0] << Block.new(old_start, '-', block[0])
              ret[1] << nil
            elsif block[0].empty?
              ret[0] << nil
              ret[1] << Block.new(new_start, '+', block[1])
            else # both blocks will have one line each.
              words = block.map { |b| b.first.scan(/\w+|[^\w+]/) }
              change_id = get_diff_change_array(words[0], words[1])
              lines = ['', '']
              for side in 0..1
                cur_text = ''
                cur_class = ''
                words[side].each_with_index do |word, j|
                  if change_id[side][j]
                    if change_id[side][j] >= 1
                      cur_class = (sprintf 'modify modify-%d', change_id[side][j])
                    elsif side == 0
                      cur_class = 'delete'
                    else
                      cur_class = 'add'
                    end
                    cur_text += word
                  else
                    unless cur_text.empty?
                      lines[side] += "<span class='#{cur_class}'>#{cur_text}</span>"
                      cur_text = ''
                    end
                    lines[side] += word
                  end
                end
                unless cur_text.empty?
                  lines[side] += "<span class='#{cur_class}'>#{cur_text}</span>"
                end
              end

              ret[0] << Block.new(old_start, '!', [lines[0]])
              ret[1] << Block.new(new_start, '!', [lines[1]])
            end
            old_start += block[0].length
            new_start += block[1].length
          end
          i += 1
        else
          ret[0] << blocks[0][i]
          ret[1] << blocks[1][i]
        end
        i += 1
      end
      ret
    end

    def diff(project_id, change_id, old_hash, new_hash, path = '')
      result = {
        :createdFiles => [],
        :deletedFiles => [],
        :updatedFiles => []
      }

      lines = Git.diff(project_id, old_hash, new_hash, path).each_line.map(&:chomp)
      i = 0
      while i < lines.length
        line = lines[i]
        i += 1
        if regex = line.match(/^diff --git a\/(.*) b\/(.*)$/)
          file = FileDiff.new(regex[1], regex[2], [0, 0], false, {
            :inline => [[], []],
            :side => [[], []],
          })
          section = :updatedFiles
          last_from_line = 1
          while i < lines.length
            line = lines[i]
            if line.start_with? 'new file'
              section = :createdFiles
            elsif line.start_with? 'deleted file'
              section = :deletedFiles
            elsif line.start_with? 'Binary files'
              file.binary = true
            elsif line.start_with? '@@'
              # line block
              if regex = line.match(/^@@ -([0-9,]+) \+([0-9,]+) @@/)
                from_start, from_lines = regex[1].split(',').map(&:to_i)
                from_lines ||= 1
                if last_from_line < from_start
                  file.blocks[:inline][0] << nil
                  file.blocks[:inline][1] << nil
                end
                last_from_line = from_start + from_lines
                to_start, to_lines = regex[2].split(',').map(&:to_i)
                to_lines ||= 1
                blocks = []
                cur_lines = []
                prev_type = nil
                start = [from_start, to_start]
                while from_lines > 0 || to_lines > 0
                  i += 1
                  line = lines[i]
                  if line[0] == '+'
                    type = '+'
                    to_lines -= 1
                  elsif line[0] == '-'
                    type = '-'
                    from_lines -= 1
                  else
                    type = '='
                    to_lines -= 1
                    from_lines -= 1
                  end
                  if !prev_type.nil? && prev_type != type
                    add_blocks prev_type, cur_lines, start, file.blocks[:inline]
                    cur_lines = []
                  end
                  cur_lines << HTMLEntities.new.encode(line[1..-1])
                  prev_type = type
                end
                unless cur_lines.empty?
                  add_blocks prev_type, cur_lines, start, file.blocks[:inline]
                end
              end
            elsif line.start_with? 'diff --git'
              break
            else
            end
            i += 1
          end

          if file.binary && file.name.end_with?('docx')
            doc1 = DocStore.retrieve(project_id, old_hash, file.name)
            doc2 = DocStore.retrieve(project_id, new_hash, file.name)
            file.blocks = YDocx::Differ.new.diff(doc1, doc2)
            file.binary = false
          elsif !file.binary
            file.blocks[:side] = generate_side_blocks(file.blocks[:inline])
          end

          file.lines_changed = file.blocks[:inline].map do |blocks|
            blocks.map { |b| (b.nil? || b.type == '=') ? 0 : b.lines.length }.reduce(0, :+)
          end
          result[section] << file
        else
          break
        end
      end
      result
    end
  end
end
