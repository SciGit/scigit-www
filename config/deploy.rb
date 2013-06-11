set :stages, %w(production staging)
set :default_stage, "staging"
require 'capistrano/ext/multistage'

set :application, "scigit-www"
set :repository,  "git@github.com:hansonw/scigit-www"
set :user, "deploy"
set :scm_passphrase, "RgnWvOwP2lP"
set :branch, "rails"
set :scm, :git

set :ssh_options, { :forward_agent => true }
set :deploy_to, "/var/www/#{application}"
set :deploy_via, :remote_cache

set :use_sudo, false

set :normalize_asset_timestamps, false

# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

#role :web, production # Your HTTP server, Apache/etc
#role :app, production # This may be the same as your `Web` server
#role :db,  production, :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
#

task :uname do
  run "uname -a"
end

after "deploy", "deploy:migrate"

# These must be at the end of the file.
set :rvm_ruby_string, '2.0.0-p195'
set :rvm_type, :system
require "bundler/capistrano"
require "rvm/capistrano"
