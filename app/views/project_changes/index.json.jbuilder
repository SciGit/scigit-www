json.array!(@project_changes) do |project_change|
  json.extract! project_change, :user_id, :project_id, :commit_msg, :commit_hash, :commit_timestamp
  json.url project_change_url(project_change, format: :json)
end