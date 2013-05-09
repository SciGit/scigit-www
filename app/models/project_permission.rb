class ProjectPermission < ActiveRecord::Base
  attr_accessible :permission, :project_id, :user_id
end
