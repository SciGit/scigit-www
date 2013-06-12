set :rails_env, "production"

server 'rails-staging.scigit.com', :app, :web, :db, :primary => true
