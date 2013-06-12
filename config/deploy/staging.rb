set :rails_env, "test"

server 'ec2-23-22-218-189.compute-1.amazonaws.com', :app, :web, :db, :primary => true
