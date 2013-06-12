set :rails_env, "production"

set :server1, 'ec2-75-101-188-41.compute-1.amazonaws.com'
set :server2, 'ec2-54-224-24-151.compute-1.amazonaws.com'

#server 'ec2-23-22-7-52.compute-1.amazonaws.com', :app, :web, :db, :primary => true
role :app, server1, server2
role :web, server1, server2
role :db, server1, server2, :primary => true
