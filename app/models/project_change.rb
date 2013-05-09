class ProjectChange < ActiveRecord::Base
  attr_accessible :commit_hash, :commit_msg, :commit_timestamp, :project_id, :user_id
end
