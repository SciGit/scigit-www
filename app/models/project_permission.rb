class ProjectPermission < ActiveRecord::Base
  belongs_to :project
  belongs_to :user

  OWNER = 3
  COAUTHOR = 2
  SUBSCRIBER = 1

  def self.get_user_permission(user, project)
    where(:user_id => user[:id], :project_id => project[:id]).first
  end

  def self.all_members_with_permission(project, flags)
    user_ids = ProjectPermission.where{
      (project_id == project[:id]) &
      (permission >> flags)
    }.pluck(:user_id);

    User.where{id >> user_ids}
  end

  def self.all_project_owners(project)
    all_members_with_permission(project, OWNER)
  end

  def self.all_project_coauthors(project)
    all_members_with_permission(project, COAUTHOR)
  end

  def self.all_project_managers(project)
    all_members_with_permission(project, [OWNER, COAUTHOR])
  end

  def self.all_project_subscribers(project)
    all_members_with_permission(project, SUBSCRIBER)
  end

  def self.all_project_members(project)
    user_ids = ProjectPermission.where{
      project_id == project[:id]}.pluck(:user_id);

    User.where{id >> user_ids}
  end
end
