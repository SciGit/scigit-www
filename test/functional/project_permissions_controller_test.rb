require 'test_helper'

class ProjectPermissionsControllerTest < ActionController::TestCase
  setup do
    @project_permission = project_permissions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:project_permissions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create project_permission" do
    assert_difference('ProjectPermission.count') do
      post :create, project_permission: { permission: @project_permission.permission, project_id: @project_permission.project_id, user_id: @project_permission.user_id }
    end

    assert_redirected_to project_permission_path(assigns(:project_permission))
  end

  test "should show project_permission" do
    get :show, id: @project_permission
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @project_permission
    assert_response :success
  end

  test "should update project_permission" do
    put :update, id: @project_permission, project_permission: { permission: @project_permission.permission, project_id: @project_permission.project_id, user_id: @project_permission.user_id }
    assert_redirected_to project_permission_path(assigns(:project_permission))
  end

  test "should destroy project_permission" do
    assert_difference('ProjectPermission.count', -1) do
      delete :destroy, id: @project_permission
    end

    assert_redirected_to project_permissions_path
  end
end
