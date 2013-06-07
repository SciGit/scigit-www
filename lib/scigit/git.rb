require 'shellwords'

module SciGit
  class Git
    @@scigit_dir = '/var/scigit'
    @@scigit_repo_dir = '/var/scigit/repos'

    def self.diff(project_id, old_hash, new_hash, path = '')
      dir = File.join(@@scigit_repo_dir, "r#{project_id}")
      old_hash = Shellwords.escape(old_hash)
      new_hash = Shellwords.escape(new_hash)
      path = Shellwords.escape(path)
      `cd #{dir}; git diff #{old_hash} #{new_hash} -- #{path}`
    end

    def self.show(project_id, commit_hash, path, out = '')
      dir = File.join(@@scigit_repo_dir, "r#{project_id}")
      commit_hash = Shellwords.escape(commit_hash)
      path = Shellwords.escape(path)
      if out
        out = ' > ' + Shellwords.escape(out)
      end
      `cd #{dir}; git show #{commit_hash}:#{path} #{out}`
    end
  end
end
