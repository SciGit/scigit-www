class ProjectChange < ActiveRecord::Base
  belongs_to :user
  belongs_to :project

  def commit_timestamp
    Time.at(self[:commit_timestamp])
  end

  def self.get_coauthor_updates(user, limit = nil)
    self.get_member_updates(user, [ProjectPermission::OWNER, ProjectPermission::COAUTHOR], limit)
  end

  def self.get_subscription_updates(user, limit = nil)
    self.get_member_updates(user, ProjectPermission::SUBSCRIBER, limit)
  end

  def self.all_project_updates(project, limit = nil)
    where{(project_id == project.id) & (user_id != 0)}.limit(limit).order{id.desc}
  end

  def self.diff(id)
    change = find(id)
    require_dependency 'scigit/diff'
    SciGit::Diff.diff(change.project_id, change.commit_hash + '^', change.commit_hash)
  end

  private

  def self.get_member_updates(user, flags, limit)
    # Get all projects this user belongs to.
    # XXX: Can't & this for some reason?
    project_ids = ProjectPermission.where{
      (permission >> flags) &
      (user_id == user[:id])
    }.pluck{project_id}

    # Get all the changes of these projects not done by this user.
    where{(project_id >> project_ids) & (user_id != user[:id]) & (user_id != 0)}.
      order{commit_timestamp.desc}.limit(limit)
  end
end
