require 'test_helper'

class TutorialsControllerTest < ActionController::TestCase
  setup do
    Dir.mkdir("/tmp/html_validation")
    @nixon = users(:nixon)
    @tutorial = tutorials(:one)
  end
  
  teardown do
    FileUtils.rm_rf("/tmp/html_validation")
  end
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tutorials)
    
    # HTML validation
    assert_valid_html(request.body, "Index Get")
  end
  
  test "should create tutorial" do
    assert_difference('Tutorial.count') do
      post :create, { tutorial: { content: @tutorial.content, title: @tutorial.title }}, { user_id: @nixon }
    end
    
    assert_redirected_to tutorial_path(assigns(:tutorial))
  end
  
  test "should show tutorial" do
    get :show, id: @tutorial
    assert_response :success
    
    # HTML validation
    assert_valid_html(request.body, "Tutorial Show")
  end
  
  test "should get edit" do
    get :edit, { id: @tutorial }, { user_id: @nixon }
    assert_response :success
    
    # HTML validation
    assert_valid_html(request.body, "Edit Get")
  end
  
  test "should update tutorial" do
    put :update, { id: @tutorial, tutorial: { content: @tutorial.content, title: @tutorial.title } }, 
      { user_id: @nixon }
    assert_redirected_to tutorial_path(assigns(:tutorial))
  end
  
  test "should destroy tutorial" do
    assert_difference('Tutorial.count', 0) do
      delete :destroy, { id: @tutorial }, { user_id: @nixon }
    end
    
    assert_redirected_to tutorials_path
  end
  
  test "should set featured tutorial" do
    post :switch, { format: 'json', tutorial: @tutorial, selected: 1 }, { user_id: @nixon }
    assert_response :success
    
    # HTML validation
    assert_valid_html(request.body, "Featured Tutorial Set")
  end
end
