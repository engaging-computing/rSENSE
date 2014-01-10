require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  setup do
    @kate = users(:kate)
  end

  test "should log in" do
    post :create, { format: 'json', email: "kcarcia@cs.uml.edu", password: "12345" }
    puts flash[:debug] if flash[:debug]
    assert_match /authenticity_token/, @response.body
    assert_response :success
  end

  test "should not log in with bad password" do
    post :create, { format: 'json', email: "kcarcia@cs.uml.edu", password: "derp" }
    assert_response 401
  end

  test "should log out" do
    get :destroy
    assert_nil session[:user_id]
    assert_response :redirect
  end

  test "verify user is not logged in" do
    get :verify, { format: 'json' }
    assert_response :unauthorized
  end

  test "verify user is logged in" do
    get :verify, { format: 'json' }, { user_id: @kate }
    assert_response :success
  end

  test "should redirect from /login to /" do
    @request.env['HTTP_REFERER'] = login_url
    get :new
    assert_response :success
    assert_equal session[:redirect_to], "/home/index"
  end
end
