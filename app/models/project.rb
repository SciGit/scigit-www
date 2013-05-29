class Project < ActiveRecord::Base
  has_many :user, :through => :project_permission
  has_many :user, :through => :project_change

  def self.all_public(limit = nil)
    self.all
  end

  def self.all_manager_of(user, limit = nil)
    self.all_member_of(user, [ProjectPermission::OWNER, ProjectPermission::COAUTHOR], limit)
  end

  def self.all_subscribed_to(user, limit = nil)
    self.all_member_of(user, ProjectPermission::SUBSCRIBER, limit)
  end

  private

  def self.all_member_of(user, flags, limit)
    project_ids = ProjectPermission.where{
      (permission >> flags) &
      (user_id == user[:id])
    }.limit(limit).pluck{project_id}

    where{id >> project_ids}
  end
end
