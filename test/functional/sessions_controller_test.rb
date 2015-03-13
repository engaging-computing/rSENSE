require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  setup do
    @kate = users(:kate)
    @project_three = projects(:three)
  end

  test 'should log in' do
    post :create,  format: 'json', email: 'kcarcia@cs.uml.edu', password: '12345'
    puts flash[:debug] if flash[:debug]
    assert_match(/authenticity_token/, @response.body)
    assert_response :success
  end

  test 'should not log in with bad password' do
    post :create,  format: 'json', email: 'kcarcia@cs.uml.edu', password: 'derp'
    assert_response 401
  end

  test 'should log out' do
    get :destroy
    assert_nil session[:user_id]
    assert_response :redirect
  end

  test 'user has save permissions' do
    get :permissions, { format: 'json' },  user_id: @kate.id
    assert_response :success
    assert JSON.parse(response.body)['permissions'].include? 'save'
  end

  test 'user has no permissions' do
    get :permissions,  format: 'json'
    assert_response :unauthorized
  end

  test 'user has project permissions' do
    get :permissions,
    {
      format: 'json',
      project_id: @project_three.id,
    }, user_id: @kate.id
    assert_response :success
    assert JSON.parse(response.body)['permissions'].include? 'project'
  end

  test 'should redirect from /login to /' do
    @request.env['HTTP_REFERER'] = login_url
    get :new
    assert_response :success
    assert_equal session[:redirect_to], '/home/index'
  end
end
