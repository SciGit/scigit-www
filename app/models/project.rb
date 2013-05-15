class Project < ActiveRecord::Base
  has_many :project_permission
  has_many :project_change
end
