require 'test_helper'

class ExperimentSessionsControllerTest < ActionController::TestCase
  setup do
    @experiment_session = experiment_sessions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:experiment_sessions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create experiment_session" do
    assert_difference('ExperimentSession.count') do
      post :create, experiment_session: { content: @experiment_session.content, experiment_id: @experiment_session.experiment_id, title: @experiment_session.title, user_id: @experiment_session.user_id }
    end

    assert_redirected_to experiment_session_path(assigns(:experiment_session))
  end

  test "should show experiment_session" do
    get :show, id: @experiment_session
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @experiment_session
    assert_response :success
  end

  test "should update experiment_session" do
    put :update, id: @experiment_session, experiment_session: { content: @experiment_session.content, experiment_id: @experiment_session.experiment_id, title: @experiment_session.title, user_id: @experiment_session.user_id }
    assert_redirected_to experiment_session_path(assigns(:experiment_session))
  end

  test "should destroy experiment_session" do
    assert_difference('ExperimentSession.count', -1) do
      delete :destroy, id: @experiment_session
    end

    assert_redirected_to experiment_sessions_path
  end
end
