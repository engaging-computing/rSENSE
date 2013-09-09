require 'test_helper'

class SessionsControllerTest < ActionController::TestCase

  # Passes if login is successful
  test "login success" do
    post :create, { format: 'json', username_or_email: "kate", password: "12345" }
    puts flash[:debug] if flash[:debug]
    assert_match /authenticity_token/, @response.body
    assert_response :success
  end

  test "should get destroy" do
    get :destroy
    assert_nil session[:user_id]
    assert_response :redirect
  end

end
