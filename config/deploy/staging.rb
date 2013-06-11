set :rails_env, "test"

server 'ec2-54-226-74-157.compute-1.amazonaws.com', :app, :web, :db, :primary => true
