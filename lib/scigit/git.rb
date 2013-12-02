require 'scigit'
require 'shellwords'

module SciGit
  class Git
    @@scigit_repo_dir = SCIGIT_DIR + '/repos'

    def self.get_hash(project_id, commit_hash, path = '')
      dir = File.join(@@scigit_repo_dir, "r#{project_id}")
      commit_hash = Shellwords.escape(commit_hash)
      unless path.empty?
        path = ':' + Shellwords.escape(path)
      end
      out = `cd #{dir}; git rev-parse #{commit_hash}#{path}`.chomp
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
      result = `cd #{dir}; git diff #{old_hash} #{new_hash} -- #{path}`
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
      result = `cd #{dir}; git show #{commit_hash}:#{path} #{out}`
      if $?.to_i == 0
        return result
      else
        return nil
      end
    end
  end
end
