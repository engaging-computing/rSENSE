require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  test "should log in" do
    post :create, { format: 'json', username_or_email: "kate", password: "12345" }
    puts flash[:debug] if flash[:debug]
    assert_match /authenticity_token/, @response.body
    assert_response :success
  end

  test "should not log in with bad password" do
    post :create, { format: 'json', username_or_email: "kate", password: "derp" }
    assert_response 403
  end

  test "should log out" do
    get :destroy
    assert_nil session[:user_id]
    assert_response :redirect
  end
end
