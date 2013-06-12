set :stages, %w(production staging development)
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

task :deploy_scripts do
  run "sudo /etc/init.d/scigit stop &&
       cd /var/scigit &&
       git pull &&
       sudo chown -hR git:deploy /var/scigit &&
       sudo /etc/init.d/scigit start"
  if !File.exists('/usr/lib/python2.7/scigitconfig.py')
    run 'sudo ln -s /usr/lib/python2.7/scigitconfig.py
                    /var/scigit/config/config.py'
  end
end

task :nginx_logs do
  run "tail -50 /etc/nginx/logs/error.log"
end

task :rails_logs do
  run "tail -50 #{current_path}/log/#{rails_env}.log"
end

after "deploy", "deploy:migrate"

# These must be at the end of the file.
set :rvm_ruby_string, '2.0.0-p195'
set :rvm_type, :system
require "bundler/capistrano"
require "rvm/capistrano"
