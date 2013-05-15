class Project < ActiveRecord::Base
  has_many :user, :through => :project_permission
  has_many :user, :through => :project_change
end
