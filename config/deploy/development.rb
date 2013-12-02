set :rails_env, "development"

username = (%x[whoami]).strip
server "rails-#{username}.scigit.com", :app, :web, :db, :primary => true
