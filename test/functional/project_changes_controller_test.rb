require 'test_helper'

class ProjectChangesControllerTest < ActionController::TestCase
  setup do
    @project_change = project_changes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:project_changes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create project_change" do
    assert_difference('ProjectChange.count') do
      post :create, project_change: { commit_hash: @project_change.commit_hash, commit_msg: @project_change.commit_msg, commit_timestamp: @project_change.commit_timestamp, project_id: @project_change.project_id, user_id: @project_change.user_id }
    end

    assert_redirected_to project_change_path(assigns(:project_change))
  end

  test "should show project_change" do
    get :show, id: @project_change
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @project_change
    assert_response :success
  end

  test "should update project_change" do
    put :update, id: @project_change, project_change: { commit_hash: @project_change.commit_hash, commit_msg: @project_change.commit_msg, commit_timestamp: @project_change.commit_timestamp, project_id: @project_change.project_id, user_id: @project_change.user_id }
    assert_redirected_to project_change_path(assigns(:project_change))
  end

  test "should destroy project_change" do
    assert_difference('ProjectChange.count', -1) do
      delete :destroy, id: @project_change
    end

    assert_redirected_to project_changes_path
  end
end
