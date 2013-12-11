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
end
