require 'test_helper'
require_relative 'api_v1_test'

class ApiV1DataSetsTest < ApiV1Test
  test 'data does not get truncated' do
    pid = @dessert_project.id
    post "/api/v1/projects/#{pid}/jsonDataUpload",

          title: 'Awesome Data',
          email: 'kcarcia@cs.uml.edu',
          password: '12345',
          data:
            {
              '20' => ['1'],
              '21' => ['1', '2', '3', '4', '5']
            }
    assert_response :success
    data_uploaded = parse(response)['data']

  end

  test 'create data set with contribution_key' do
    pid = @dessert_project.id
    post "/api/v1/projects/#{pid}/jsonDataUpload",

          title: 'Awesome Data',
          contribution_key: 'apple',
          contributor_name: 'Student 1',
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

  test 'failed create data set same name' do
    pid = @dessert_project.id
    post "/api/v1/projects/#{pid}/jsonDataUpload",

          title: 'Awesome Data',
          contribution_key: 'apple',
          data:
            {
              '20' => ['1', '2', '3', '4', '5']
            }

    assert_response :unprocessable_entity
  end

  test 'failed create data set with contribution_key no name' do
    post "/api/v1/projects/#{@dessert_project.id}/jsonDataUpload",

          title: @dessert_project.data_sets.first.title,
          contribution_key: 'apple',
          contributor_name: 'Studnet 2',
          data:
            {
              '20' => ['1', '2', '3', '4', '5']
            }
    assert_response :unprocessable_entity
    assert parse(response)['error'][0] == "Title \"Thanksgiving Dinner\" is taken.",
        "Message should be Title \"Thanksgiving Dinner\" is taken."
  end

  test 'failed create data set with bad contribution_key' do
    pid = @dessert_project.id
    post "/api/v1/projects/#{pid}/jsonDataUpload",

          title: 'Awesome Data',
          contribution_key: 'blueberry',
          contributor_name: 'Student 1',
          data:
            {
              '20' => ['1', '2', '3', '4', '5']
            }

    assert_response :unauthorized
  end

  test 'failed create data set' do
    assert_difference('DataSet.count', 0) do
      pid = @dessert_project.id
      post "/api/v1/projects/#{pid}/jsonDataUpload?data[20][]=2&data[20][]=3&title=AwesomeData"
      assert_response :unauthorized
    end
  end

  test 'edit data set' do
    dset_id = @dessert_project.data_sets.first.id

    get "/api/v1/data_sets/#{dset_id}?recur=true"
    assert_response :success
    old_data = parse(response)['data']

    get "/api/v1/data_sets/#{dset_id}/edit",

        email: 'kcarcia@cs.uml.edu',
        password: '12345',
        data:
          {
            '20' => ['5']
          }

    assert_response :success

    get "/api/v1/data_sets/#{dset_id}?recur=true"
    assert_response :success
    new_data = parse(response)['data']

    assert new_data != old_data, 'Data didnt get updated'
    assert new_data[0]['20'] == '5', 'First point should have been updated to 5'
  end

  test 'failed edit data set' do
    dset_id = @dessert_project.data_sets.first.id

    get "/api/v1/data_sets/#{dset_id}?recur=true"
    assert_response :success
    old_data = parse(response)['data']

    get "/api/v1/data_sets/#{dset_id}/edit?data[20][]=5&data[21][]=6&data[22][]=7"
    assert_response :unauthorized

    get "/api/v1/data_sets/#{dset_id}?recur=true"
    assert_response :success
    new_data = parse(response)['data']

    assert new_data == old_data, 'Data didnt get updated'
  end

  test 'fail append to data set (not found)' do
    post '/api/v1/data_sets/append',
        id: 2,
        email: 'kcarcia@cs.uml.edu',
        password: '12345'
    assert_response :not_found
  end

  test 'append to data set' do
    post '/api/v1/data_sets/append',
        id: @dessert_project.data_sets.first.id,
        email: 'kcarcia@cs.uml.edu',
        password: '12345',
        data:
          {
            '20' => ['99', '100', '101'],
            '21' => ['102', '103', '104'],
            '22' => ['105', '106', '107']
          }
    assert_response :success

    data = parse(response)['data']
    some_new_data = { '20' => '99', '21' => '102', '22' => '105' }

    assert data.include?(some_new_data), 'Updated data did not include new data points'
  end

  test 'fail append to data set (unauthorized)' do
    post '/api/v1/data_sets/append',
        id: @dessert_project.data_sets.first.id,
        email: 'boxes@boxes.boxes',
        password: '12345',
        data:
          {
            '20' => ['blue', '100', '101'],
            '21' => ['102', '103', '104'],
            '22' => ['105', '106', '107']
          }

    assert_response :unauthorized
  end

  test 'fail append to data set (failed sanitization)' do
    post '/api/v1/data_sets/append',
        id: @dessert_project.data_sets.first.id,
        email: 'kcarcia@cs.uml.edu',
        password: '12345',
        data:
          {
            '20' => ['blue', '100', '101'],
            '21' => ['102', '103', '104'],
            '22' => ['105', '106', '107']
          }
    assert_response :unprocessable_entity
    assert !parse(response)['error'].nil?
  end

  test 'append to data set (contribution_key)' do
    post '/api/v1/data_sets/append',
        id: @dessert_project.data_sets.first.id,
        contribution_key: 'apple',
        data:
          {
            '20' => ['1000'],
            '21' => ['1001'],
            '22' => ['1002']
          }
    assert_response :success

    data = parse(response)['data']
    some_new_data = { '20' => '1000', '21' => '1001', '22' => '1002' }

    assert data.include?(some_new_data), 'Updated data did not include new data points'
  end

  test 'fail append to data set (bad contribution_key)' do
    post '/api/v1/data_sets/append',
        id: @dessert_project.data_sets.first.id,
        contribution_key: 'blueberry',
        data:
          {
            '20' => ['1000'],
            '21' => ['1001'],
            '22' => ['1002']
          }
    assert_response :unauthorized
  end
end
