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
      @context = 3
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

    def trim_context(blocks)
      len = blocks[0].length
      lines_till_change = Array.new(len)
      count = @context
      blocks[0].reverse.each_with_index do |block, ii|
        i = len - 1 - ii
        if block.nil? || block.type != '='
          lines_till_change[i] = 0
          count = 0
        else
          lines_till_change[i] = count
          count += block.lines.length
        end
      end

      result = [[], []]
      count = @context
      last_nil = false
      blocks[0].each_with_index do |block, i|
        if block.nil? || block.type != '='
          result[0] << block
          result[1] << blocks[1][i]
          count = 0
        else
          m = block.lines.length
          from_start = count > @context ? 0 : @context - count
          from_end = lines_till_change[i] > @context ? 0 : @context - lines_till_change[i]
          if from_start + from_end >= m
            result[0] << block
            result[1] << blocks[1][i]
            last_nil = false
          else
            if from_start > 0
              result[0] << Block.new(block.start_line, '=', block.lines[0, from_start])
              result[1] << Block.new(blocks[1][i].start_line, '=', block.lines[0, from_start])
              last_nil = false
            end
            if !last_nil
              result[0] << nil
              result[1] << nil
              last_nil = true
            end
            if from_end > 0
              result[0] << Block.new(block.start_line+m-from_end, '=', block.lines[m-from_end..m-1])
              result[1] << Block.new(blocks[1][i].start_line+m-from_end, '=', block.lines[m-from_end..m-1])
              last_nil = false
            end
          end
          count += m
        end
      end
      result
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
            file.blocks = DocStore.retrieve_diff(project_id, old_hash, new_hash, file.name)
            file.blocks.each do |key, blocks|
              file.blocks[key] = trim_context(blocks)
            end
            file.binary = false
          elsif !file.binary
            file.blocks[:side] = YDocx::Differ.new.diff_text(file.blocks[:inline])
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
