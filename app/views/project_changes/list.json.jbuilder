json.array! @project_changes do |project_change|
  json.extract! project_change, :commit_msg, :commit_hash, :commit_timestamp, :created_at, :updated_at
  json.user_id project_change.user[:id]
  json.user_fullname project_change.user[:fullname]
end
