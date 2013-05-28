class Project < ActiveRecord::Base
  has_many :user, :through => :project_permission
  has_many :user, :through => :project_change

  def self.all_manager_of(user)
    self.all_member_of(user, [ProjectPermission::OWNER, ProjectPermission::COAUTHOR])
  end

  def self.all_subscribed_to(user)
    self.all_member_of(user, ProjectPermission::SUBSCRIBER)
  end

  private

  def self.all_member_of(user, flags)
    project_ids = ProjectPermission.where{
      (permission >> flags) &
      (user_id == user[:id])
    }.pluck{project_id}

    where{id >> project_ids}
  end
end
