require 'test_helper'

class VisualizationsControllerTest < ActionController::TestCase
  setup do
    @kate = users(:kate)
    @admin = users(:nixon)

    @vis1 = visualizations(:visualization1)

    @vis2 = visualizations(:visualization2)
    @vis2.save
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:visualizations)
  end

  test "should create visualization" do
    assert_difference('Visualization.count') do
      post :create, {visualization: { content: @vis1.content, data: @vis1.data, project_id: @vis1.project_id, 
        globals: @vis1.globals, title: @vis1.title, user_id: @vis1.user_id }}, { user_id: @kate.id }
    end

    assert_redirected_to visualization_path(assigns(:visualization))
  end

  test "should show visualization" do
    get :show, { id: @vis2.id }, { user_id: @kate.id }
    assert_response :success
  end

  test "should get edit" do
    get :edit, { id: @vis2 }, { user_id: @admin }
    assert_response :success
  end

  test "should update visualization" do
    put :update, { id: @vis2, visualization: { content: @vis1.content, data: @vis1.data, 
      project_id: @vis1.project_id, globals: @vis1.globals, title: @vis1.title, user_id: @vis1.user_id } },
      { user_id: @kate.id }
    assert_redirected_to visualization_path(assigns(:visualization))
  end

  test "should destroy visualization" do
    assert_difference('Visualization.count', 0) do
      delete :destroy, { id: @vis2 }, { user_id: @kate.id }
    end

    assert_redirected_to visualizations_path
  end
end
