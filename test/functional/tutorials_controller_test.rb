require 'test_helper'

class TutorialsControllerTest < ActionController::TestCase
  setup do
    @nixon = users(:nixon)
    @kate  = users(:kate)
    @tutorial = tutorials(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tutorials)
  end

  test "should create tutorial" do
    assert_difference('Tutorial.count') do
      post :create, { tutorial: { content: @tutorial.content, title: @tutorial.title }}, { user_id: @nixon }
    end

    assert_redirected_to tutorial_path(assigns(:tutorial))
  end

  test "should not create tutorial as non-admin" do
    assert_difference('Tutorial.count', 0) do
      post :create, { tutorial: { content: @tutorial.content, title: @tutorial.title }}, { user_id: @kate }
    end

    assert_response :not_found
  end


  test "should show tutorial" do
    get :show, id: @tutorial
    assert_response :success
  end

  test "should get edit" do
    get :edit, { id: @tutorial }, { user_id: @nixon }
    assert_response :success
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

  test "should not destroy tutorial as non-admin" do
    assert_difference('Tutorial.count', 0) do
      delete :destroy, { id: @tutorial }, { user_id: @kate }
    end

    assert_redirected_to '/public/401.html'
  end


end
