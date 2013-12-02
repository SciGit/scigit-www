require 'scigit/docstore'

class Project < ActiveRecord::Base
  has_many :user, :through => :project_permission
  has_many :user, :through => :project_change

  validates :name, :presence => true, :uniqueness => true, :length => {:in => 4..64}
  validates :description, :length => {:maximum => 255}
  validates :public, :inclusion => {:in => [true, false]}, :allow_blank => true

  def get_doc_file(doc_hash, file)
    SciGit::DocStore.get_file(id, doc_hash, file)
  end

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
