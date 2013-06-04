require 'shellwords'

module SciGit
  class Diff
    @@scigit_dir = '/var/scigit'
    @@scigit_repo_dir = '/var/scigit/repos'
    Block = Struct.new(:start_line, :type, :lines)
    FileDiff = Struct.new(:name, :new_name, :binary, :old_blocks, :new_blocks)

    def self.diff(project_id, old_hash, new_hash, path = '')
      dir = File.join(@@scigit_repo_dir, "r#{project_id}")
      old_hash = Shellwords.escape(old_hash)
      new_hash = Shellwords.escape(new_hash)
      path = Shellwords.escape(path)

      result = {
        :createdFiles => [],
        :deletedFiles => [],
        :updatedFiles => []
      }

      output = `cd #{dir}; git diff #{old_hash} #{new_hash} -- #{path}`
      lines = output.each_line.map(&:chomp)
      i = 0
      while i < lines.length
        line = lines[i]
        i += 1
        if regex = line.match(/^diff --git a\/(.*) b\/(.*)$/)
          file = FileDiff.new(regex[1], regex[2], false, [], [])
          section = :updatedFiles
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
                to_start, to_lines = regex[2].split(',').map(&:to_i)
                to_lines ||= 1
                blocks = []
                cur_lines = []
                prev_type = nil
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
                    if prev_type == '-' || prev_type == '='
                      file.old_blocks << Block.new(from_start, prev_type, cur_lines)
                      file.new_blocks << nil unless prev_type == '='
                      from_start += cur_lines.length
                    end
                    if prev_type == '+' || prev_type == '='
                      file.old_blocks << nil unless prev_type == '='
                      file.new_blocks << Block.new(to_start, prev_type, cur_lines)
                      to_start += cur_lines.length
                    end
                    cur_lines = []
                  end
                  cur_lines << line[1..-1]
                  prev_type = type
                end
                unless cur_lines.empty?
                  if type == '-' || type == '='
                    file.old_blocks << Block.new(from_start, type, cur_lines)
                    file.new_blocks << nil unless type == '='
                  end
                  if type == '+' || type == '='
                    file.old_blocks << nil unless type == '='
                    file.new_blocks << Block.new(to_start, type, cur_lines)
                  end
                end
              end
            elsif line.start_with? 'diff --git'
              break
            else
            end
            i += 1
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
