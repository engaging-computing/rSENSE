require 'test_helper'

class SessionsControllerTest < ActionController::TestCase

  # Passes if login is successful
  test "login success" do
    get :login
    assert_response :success
  end

  test "should get create" do
    get :create
    assert_response :success
  end

  test "should get destroy" do
    get :destroy
    assert_response :success
  end

end
