require 'test_helper'
require_relative 'api_v1_test'

class ApiV1UsersTest < ApiV1Test
  test 'get user info' do
    get '/api/v1/users/myInfo',
        email: 'kcarcia@cs.uml.edu',
        password: '12345'

    assert_response :success
    assert keys_match(response, @user_keys), 'Keys are missing'
  end

  test 'fail get user info' do
    get '/api/v1/users/myInfo',
        email: 'kcarcia@cs.uml.edu',
        password: '1234'

    assert_response :unauthorized
  end
end
