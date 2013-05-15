class ProjectPermission < ActiveRecord::Base
  belongs_to :project
  belongs_to :user

  MANAGE = 3
  UPDATE = 2
  READ = 1

  def self.get_user_permission(user, project)
    where(:user_id => user[:id], :project_id => project[:id]).first
  end
end
