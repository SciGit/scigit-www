class ProjectPermission < ActiveRecord::Base
  belongs_to :project
  belongs_to :user
  accepts_nested_attributes_for :project
  accepts_nested_attributes_for :user

  OWNER = 3
  COAUTHOR = 2
  SUBSCRIBER = 1

  validates_presence_of :project
  validates_associated :project
  validates_presence_of :user
  validates_associated :user
  validates :permission, :inclusion => [SUBSCRIBER, COAUTHOR, OWNER]
  validates_uniqueness_of :user, :scope => :project, :message => "is already a member of this project"

  def self.get_user_permission(user, project)
    where(:user_id => user[:id], :project_id => project[:id]).first
  end

  def self.all_project_owners(project, limit = nil)
    all_members_with_permission(project, OWNER, limit)
  end

  def self.all_project_coauthors(project, limit = nil)
    all_members_with_permission(project, COAUTHOR, limit)
  end

  def self.all_project_managers(project, limit = nil)
    all_members_with_permission(project, [OWNER, COAUTHOR], limit)
  end

  def self.all_project_subscribers(project, limit = nil)
    all_members_with_permission(project, SUBSCRIBER, limit)
  end

  def self.all_project_members(project, limit = nil)
    user_ids = ProjectPermission.where{
      project_id == project[:id]}.pluck(:user_id);

    User.where{id >> user_ids}.limit(limit)
  end

  private

  def self.all_members_with_permission(project, flags, limit)
    user_ids = ProjectPermission.where{
      (project_id == project[:id]) &
      (permission >> flags)
    }.pluck(:user_id);

    User.where{id >> user_ids}.limit(limit)
  end
end
