require 'test_helper'
require_relative 'api_v1_test'

class ApiV1ContribKeysTest < ApiV1Test
  test 'check if key exists through API' do
    pid = @dessert_project.id
    get "/api/v1/projects/#{pid}/key",
        contribution_key: 'apple'
    assert_response 302
  end

  test 'check if key exists through API (key not found)' do
    pid = @dessert_project.id
    get "/api/v1/projects/#{pid}/key",
        contribution_key: 'not real'
    assert_response 404
  end

  test 'check if key exists through API (bad params)' do
    pid = @dessert_project.id
    get "/api/v1/projects/#{pid}/key"
    assert_response :unprocessable_entity
  end

  test 'check if key exists through API (project does not exist)' do
    pid = 123454321
    get "/api/v1/projects/#{pid}/key",
      contribution_key: 'apple'
    assert_response :not_found
  end

  test 'add a key to a project' do
    post '/api/v1/projects',

    email: 'kcarcia@cs.uml.edu',
    password: '12345'

    assert_response :success
    id = parse(response)['id']

    post "/api/v1/projects/#{id}/add_key",
        email: 'kcarcia@cs.uml.edu',
        password: '12345',
        contrib_key:
          {
            'name' => 'key_name',
            'key' => 'key'
          }
    assert_response :created
  end

  test 'add a key to a project unauthorized' do
    post '/api/v1/projects',

    email: 'kcarcia@cs.uml.edu',
    password: '12345'

    assert_response :success
    id = parse(response)['id']

    post "/api/v1/projects/#{id}/add_key",
        email: 'nixon@whitehouse.gov',
        password: '12345',
        contrib_key:
          {
            'name' => 'key_name',
            'key' => 'key'
          }
    assert_response :unauthorized
  end

  test 'add a key to a project unprocessable' do
    post '/api/v1/projects',

      email: 'kcarcia@cs.uml.edu',
      password: '12345'

    assert_response :success
    id = parse(response)['id']

    post "/api/v1/projects/#{id}/add_key",

        email: 'kcarcia@cs.uml.edu',
        password: '12345',
        wrong_name:
          {
            'wrong_name2' => 'key_name',
            'key' => 'key'
          }

    assert_response :unprocessable_entity
  end

  test 'add a key with missing key name' do
    post '/api/v1/projects',

      email: 'kcarcia@cs.uml.edu',
      password: '12345'

    assert_response :success
    id = parse(response)['id']

    post "/api/v1/projects/#{id}/add_key",

        email: 'kcarcia@cs.uml.edu',
        password: '12345',
        contrib_key:
          {
            'wrong_name2' => 'key_name',
            'key' => 'key'
          }

    assert_response :unprocessable_entity
  end

  test 'add a key with missing key value' do
    post '/api/v1/projects',

      email: 'kcarcia@cs.uml.edu',
      password: '12345'

    assert_response :success
    id = parse(response)['id']

    post "/api/v1/projects/#{id}/add_key",

        email: 'kcarcia@cs.uml.edu',
        password: '12345',
        contrib_key:
          {
            'name' => 'key_name',
            'wrong_name3' => 'key'
          }

    assert_response :unprocessable_entity
  end

  test 'add a key with really long name' do
    post '/api/v1/projects',

      email: 'kcarcia@cs.uml.edu',
      password: '12345'

    assert_response :success
    id = parse(response)['id']

    assert_difference 'ContribKey.count', 0 do
      post "/api/v1/projects/#{id}/add_key",

          email: 'kcarcia@cs.uml.edu',
          password: '12345',
          contrib_key:
            {
              'name' => 'W' * 999,
              'key' => 'key'
            }

      assert_response :unprocessable_entity
    end
  end

  test 'add a key that already exists' do
    post "/api/v1/projects/#{@dessert_project.id}/add_key",
        email: 'kcarcia@cs.uml.edu',
        password: '12345',
        contrib_key:
          {
            'name' => 'Pies',
            'key' => 'apple'
          }

    assert_response :conflict
  end
end
