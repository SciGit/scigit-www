module ProjectsHelper
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

  def path_breadcrumb(path, project, change)
    result = ""
    if path.blank?
      result += 'Project Files'
    else
      result += link_to('Project Files', files_project_path(project, :change => change.id))
    end

    parts = (path || '').split('/')
    parts.each_with_index do |part, i| 
      result += " / "
      if i != parts.length - 1
        result += link_to(part, files_project_path(project, {:path => parts[0..i].join('/'), :change => change.id}))
      else
        result += part
      end
    end

    result
  end
end
