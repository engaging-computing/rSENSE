require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase
  setup do
    @nixon   = users(:nixon)
    @kate    = users(:kate)
    @project = projects(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:projects)
  end

  test "should get index (json)" do
    get :index, { format: 'json' }
    assert_response :success
    assert_not_nil assigns(:projects)
  end

  test "should show project" do
    get :show, { id: @project }
    assert_response :success
  end
 
  test "should show project (json)" do
    get :show, { format: 'json', id: @project }
    assert_response :success
  end
 
  test "should create project" do
    assert_difference('Project.count') do
      post :create, { project: { content: @project.content, title: @project.title, user_id: @project.user_id }},
        { user_id: @nixon }
    end

    assert_redirected_to project_path(assigns(:project))
  end

  test "should create project (json)" do
    assert_difference('Project.count') do
      post :create, { format: 'json', project: { content: @project.content, title: @project.title, 
        user_id: @project.user_id }}, { user_id: @nixon }
    end

    assert_response :success
  end

  test "should get edit" do
    get :edit, { id: @project }, { user_id: @nixon }
    assert_response :success
  end

  test "should update project" do
    put :update, { id: @project, project: { content: @project.content, title: @project.title,
      user_id: @project.user_id }}, { user_id: @nixon }
    assert_redirected_to project_path(assigns(:project))
  end

  test "should update project (json)" do
    put :update, { format: 'json', id: @project, project: { content: @project.content, title: @project.title,
      user_id: @project.user_id }}, { user_id: @nixon }
    assert_response :success
  end

  test "should destroy project" do
    assert_difference('Project.count', 0) do
      delete :destroy, { id: @project }, { user_id: @nixon }
    end

    @p0 = Project.find(@project.id)
    assert @p0.hidden, "Project Got Hidden"

    assert_redirected_to projects_path
  end

  test "should destroy project (json)" do
    assert_difference('Project.count', 0) do
      delete :destroy, { format: 'json', id: @project }, { user_id: @nixon }
    end

    @p0 = Project.find(@project.id)
    assert @p0.hidden, "Project Got Hidden"

    assert_response :success
  end

  test "should like project" do
    post :updateLikedStatus, { format: 'json', id: @project }, { user_id: @kate }
    assert_response :success
  end
end
