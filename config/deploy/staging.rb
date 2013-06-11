set :rails_env, "test"

server 'ec2-107-22-121-32.compute-1.amazonaws.com', :app, :web, :db, :primary => true
