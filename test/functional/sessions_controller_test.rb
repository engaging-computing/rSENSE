require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  setup do
    @kate = users(:kate)
    @project_three = projects(:three)
  end

  test 'should log in' do
    skip('No longer valid as of devise integration')
  end

  test 'should not log in with bad password' do
    skip('No longer valid as of devise integration')
  end

  test 'should log out' do
    skip('No longer valid as of devise integration')
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
      project_id: @project_three.id
    }, user_id: @kate.id
    assert_response :success
    assert JSON.parse(response.body)['permissions'].include? 'project'
  end

  test 'should redirect from /login to /' do
    skip('No longer valid as of devise integration')
  end
end
