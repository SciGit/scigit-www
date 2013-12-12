require 'scigit'
require 'shellwords'

module SciGit
  class Git
    @@scigit_repo_dir = SCIGIT_DIR + '/repos'

    class GitFile
      attr_accessor :name, :path, :type, :size

      def initialize(name, path, type, size)
        @name = name
        @path = path
        @type = type
        @size = size
      end
    end

    def self.get_hash(project_id, commit_hash, path = '')
      dir = File.join(@@scigit_repo_dir, "r#{project_id}")
      commit_hash = Shellwords.escape(commit_hash)
      unless path.empty?
        path = ':' + Shellwords.escape(path)
      end
      out = `cd #{dir} && git rev-parse #{commit_hash}#{path}`.chomp
      if $?.to_i == 0
        return out
      else
        return nil
      end
    end

    def self.diff(project_id, old_hash, new_hash, path = '')
      dir = File.join(@@scigit_repo_dir, "r#{project_id}")
      old_hash = Shellwords.escape(old_hash)
      new_hash = Shellwords.escape(new_hash)
      path = Shellwords.escape(path)
      result = `cd #{dir} && git diff #{old_hash} #{new_hash} -- #{path}`
      if $?.to_i == 0
        return result
      else
        return nil
      end
    end

    def self.show(project_id, commit_hash, path, out = '')
      dir = File.join(@@scigit_repo_dir, "r#{project_id}")
      commit_hash = Shellwords.escape(commit_hash)
      path = Shellwords.escape(path)
      unless out.empty?
        out = ' > ' + Shellwords.escape(out)
      end
      result = `cd #{dir} && git show #{commit_hash}:#{path} #{out}`
      if $?.to_i == 0
        return result
      else
        return nil
      end
    end

    def self.file_type(project_id, commit_hash, path = '')
      if path == ''
        return 'tree'
      end

      dir = File.join(@@scigit_repo_dir, "r#{project_id}")
      commit_hash = Shellwords.escape(commit_hash)
      path = Shellwords.escape(path)
      output = `cd #{dir} && git ls-tree -l #{commit_hash} #{path}`
      if $?.to_i == 0
        # Sample line: 100644 blob 7a2a4e9ee60421ff5ef64731d06573316bf35e17      25    README
        lines = output.split("\n")
        if lines.length == 1
          parts = lines.first.split(" ", 5)
          return parts[1]
        end
      end

      return nil
    end

    def self.file_listing(project_id, commit_hash, path = '')
      dir = File.join(@@scigit_repo_dir, "r#{project_id}")
      commit_hash = Shellwords.escape(commit_hash)
      if !path.empty? && path[-1] != '/'
        path += '/'
      end
      path = Shellwords.escape(path)
      output = `cd #{dir} && git ls-tree -l #{commit_hash} #{path}`
      if $?.to_i == 0
        # Sample line: 100644 blob 7a2a4e9ee60421ff5ef64731d06573316bf35e17      25    README
        return output.split("\n").map { |line|
          parts = line.split(" ", 5)
          GitFile.new(parts[4].split('/').last, parts[4], parts[1], parts[3].to_i)
        }.sort_by { |x| [x.type == 'tree' ? 0 : 1, x.name] }
      else
        return nil
      end
    end
  end
end
