json.array!(@project_permissions) do |project_permission|
  json.extract! project_permission, :user_id, :project_id, :permission
  json.url project_permission_url(project_permission, format: :json)
end