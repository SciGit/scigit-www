module ProjectsHelper
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
