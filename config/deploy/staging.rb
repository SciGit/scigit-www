set :rails_env, "production"

server 'ec2-23-22-255-175.compute-1.amazonaws.com', :app, :web, :db, :primary => true
