# Include HipChat notifications
require 'hipchat/capistrano'

set :application, 'scigit-www'
set :repo_url, 'git@github.com:SciGit/scigit-www.git'
set :branch, 'master'
set :deploy_to, '/var/www/scigit-www'
set :ssh_options, { :forward_agent => true }
set :deploy_via, :remote_cache

set :hipchat_token, "bd9b46d4ed59c6589d40188658cdb6"
set :hipchat_room_name, "SciGit"
set :hipchat_announce, true

set :format, :pretty
set :keep_releases, 5

set :rvm_type, :system

# set :use_sudo, true

# set :log_level, :debug
# set :pty, true

# set :linked_files, %w{config/database.yml}
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# set :default_env, { path: "/opt/ruby/bin:$PATH" }

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
      execute :touch, '/tmp/voror/scigit'
    end
  end

  task :cleanup_submodules do
    on roles(:app) do
      execute :rm, '--force', '--recursive', "#{fetch :tmp_dir}/#{fetch :application}-clone"
    end
  end

  task :update_submodules do
    on roles(:app) do
      within repo_path do
        execute :git, :clone, "-b #{fetch :branch}", '--single-branch', '--recursive', '.', "#{fetch :tmp_dir}/#{fetch :application}-clone"
      end
      within "#{fetch :tmp_dir}/#{fetch :application}-clone" do
        execute :git, :submodule, :foreach, 'git pull origin master'
      end
      execute :cp, '--recursive', "#{fetch :tmp_dir}/#{fetch :application}-clone/scripts/*", "#{release_path}/scripts/"
    end
  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  before :starting, 'deploy:cleanup_submodules'
  before 'assets:precompile', 'deploy:update_submodules'
  after :finishing, 'deploy:cleanup_submodules'
  after :finishing, 'deploy:cleanup'
  after :finishing, 'deploy:restart'

end
