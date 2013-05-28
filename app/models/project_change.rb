class ProjectChange < ActiveRecord::Base
  belongs_to :user
  belongs_to :project

  def commit_timestamp
    Time.at(self[:commit_timestamp])
  end

  def self.get_coauthor_updates(user)
    self.get_member_updates(user, [ProjectPermission::OWNER, ProjectPermission::COAUTHOR])
  end

  def self.get_subscription_updates(user)
    self.get_member_updates(user, ProjectPermission::SUBSCRIBER)
  end

  def self.all_project_updates(project)
    where{project_id == project.id}
  end

  private

  def self.get_member_updates(user, flags)
    # Get all projects this user belongs to.
    # XXX: Can't & this for some reason?
    project_ids = ProjectPermission.where{
      (permission >> flags) &
      (user_id == user[:id])
    }.pluck{project_id}

    # Get all the changes of these projects not done by this user.
    where{(project_id >> project_ids) & (user_id != user[:id])}.order{commit_timestamp.desc}
  end
end
