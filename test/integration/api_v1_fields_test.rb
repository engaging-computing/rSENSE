require 'test_helper'
require_relative 'api_v1_test'

class ApiV1FieldsTest < ApiV1Test
  # Create a field with auto-generated name
  test 'create fields' do
    post '/api/v1/projects',

          email: 'kcarcia@cs.uml.edu',
          password: '12345'

    assert_response :success
    id = parse(response)['id']

    post "/api/v1/fields?field[project_id]=#{id}&field[field_type]=1&email=kcarcia%40cs%2Euml%2Eedu&password=12345"
    assert_response :success
    assert keys_match(response, @field_keys), 'Keys are missing'
  end

  # Create a named field
  test 'create fields named' do
    post '/api/v1/projects?email=kcarcia%40cs%2Euml%2Eedu&password=12345'
    assert_response :success
    id = parse(response)['id']

    post "/api/v1/fields?field[name]=Fieldy&field[project_id]=#{id}&field[field_type]=1&email=kcarcia%40cs%2Euml%2Eedu&password=12345"
    assert_response :success
    assert keys_match(response, @field_keys), 'Keys are missing'
  end

  # Create field with restrictions
  test 'create fields with restrictions' do
    post '/api/v1/projects',

          email: 'kcarcia@cs.uml.edu',
          password: '12345'

    assert_response :success
    id = parse(response)['id']

    post '/api/v1/fields',

          email: 'kcarcia@cs.uml.edu',
          password: '12345',
          field:
            {
              name: 'Favorite Color',
              project_id: id,
              field_type: 3,
              restrictions: 'Red,Green,Blue'
            }

    assert_response :success
    assert keys_match(response, @field_keys), 'Keys are missing'
  end

  # Failed field creation.
  test 'failed create fields' do
    # Bad auth
    assert_difference('Field.count', 0) do
      post '/api/v1/fields',

          email: 'kcarcia@cs.uml.edu',
          password: 'WRONG PASSWORD',
          field:
            {
              name: 'Field 1',
             project_id: @dessert_project.id,
             field_type: 3
            }

      assert_response :unauthorized
    end

    # Bad project id
    assert_difference('Field.count', 0) do
      post '/api/v1/fields',

          email: 'kcarcia@cs.uml.edu',
          password: '12345',
          field:
            {
              name: 'Field 1',
             project_id: 3,
             field_type: 3
            }

      assert_response :unprocessable_entity
    end

    # Bad field id
    assert_difference('Field.count', 0) do
      post '/api/v1/fields',

          email: 'kcarcia@cs.uml.edu',
          password: '12345',
          field:
            {
              name: 'Field 1',
             project_id: @dessert_project.id,
             field_type: 10
            }

      assert_response :unprocessable_entity
    end

    # Same Name
    assert_difference('Field.count', 0) do
      post '/api/v1/fields',

          email: 'kcarcia@cs.uml.edu',
          password: '12345',
          field:
            {
              name: 'pie',
             project_id: @dessert_project.id,
             field_type: 3
            }

      assert_response :unprocessable_entity
    end
  end

  test 'get field' do
    get '/api/v1/fields/20'
    assert_response :success
    assert keys_match(response, @field_keys), 'Keys are missing'
  end

  test 'create data set' do
    pid = @dessert_project.id
    post "/api/v1/projects/#{pid}/jsonDataUpload",

          title: 'Awesome Data',
          email: 'kcarcia@cs.uml.edu',
          password: '12345',
          data:
            {
              '20' => ['1', '2', '3', '4', '5']
            }

    assert_response :success
    assert keys_match(response, @data_keys), 'Keys are missing'

    id = parse(response)['id']
    get "/api/v1/data_sets/#{id}?recur=true"
    assert_response :success
    assert keys_match(response, @data_keys_extended), 'Keys are missing'
  end
end
