module ProjectPermissionsHelper
  def project_subscribers(project)
    permissions = ProjectPermission.where(:project => project)
    permissions.select{ |permission| permission.user.can? :subscribed, permission.project }
  end

  def project_members(project)
    permissions = ProjectPermission.where(:project => project)
    permissions.select{ |permission| permission.user.can? :read, permission.project }
  end

  def project_coauthors(project)
    permissions = ProjectPermission.where(:project => project)
    permissions.select{ |permission| permission.user.can? :update, permission.project }
  end
end
