require 'test_helper'

class TutorialsControllerTest < ActionController::TestCase
  setup do
    @tutorial = tutorials(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tutorials)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tutorial" do
    assert_difference('Tutorial.count') do
      post :create, tutorial: { content: @tutorial.content, title: @tutorial.title }
    end

    assert_redirected_to tutorial_path(assigns(:tutorial))
  end

  test "should show tutorial" do
    get :show, id: @tutorial
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @tutorial
    assert_response :success
  end

  test "should update tutorial" do
    put :update, id: @tutorial, tutorial: { content: @tutorial.content, title: @tutorial.title }
    assert_redirected_to tutorial_path(assigns(:tutorial))
  end

  test "should destroy tutorial" do
    assert_difference('Tutorial.count', -1) do
      delete :destroy, id: @tutorial
    end

    assert_redirected_to tutorials_path
  end
end
