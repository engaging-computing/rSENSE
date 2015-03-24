require 'test_helper'

class ApiV1Test < ActionDispatch::IntegrationTest
  setup do
    @project_keys = ['id', 'featuredMediaId', 'name', 'url', 'path', 'hidden', 'featured', 'likeCount', 'content', 'timeAgoInWords', 'createdAt', 'ownerName', 'ownerUrl', 'dataSetCount', 'fieldCount', 'fields']
    @project_keys_extended = @project_keys + ['dataSets', 'mediaObjects', 'owner']
    @field_keys = ['id', 'name', 'type', 'unit', 'restrictions']
    @data_keys = ['id', 'name', 'ownerId', 'ownerName', 'contribKey', 'url', 'path', 'createdAt', 'fieldCount', 'datapointCount', 'displayURL', 'data']
    @data_keys_extended = @data_keys + ['owner', 'project', 'fields']
    @dessert_project = projects(:dessert)
    @thanksgiving_dataset = data_sets(:thanksgiving)
    @media_object_keys = ['id', 'mediaType', 'name', 'url', 'createdAt', 'src', 'tn_src']
    @media_object_keys_extended = @media_object_keys + ['project', 'owner']
    @user_keys = ['gravatar', 'name']

    @test_proj = projects(:media_test)
  end

  # Get projects listing using defaults
  test 'get projects index' do
    get '/api/v1/projects'
    assert_response :success
    assert parse(response).class == Array, 'Response should be an array'
  end

  # Get projects listing sorted/ordered
  test 'get projects sorted and ordered' do
    get '/api/v1/projects?sort=created_at&order=DESC'
    assert_response :success
    resp = parse(response)
    cur = Date.parse(resp[0]['createdAt'])
    resp.each do |p|
      next_date = Date.parse(p['createdAt'])
      assert next_date <= cur, 'Results not in DESC order'
      cur = next_date
    end
  end

  # Get projects listing paged.
  test 'get projects index paged' do
    get '/api/v1/projects?per_page=3&page=2'
    assert_response :success
    assert parse(response).length <= 3, 'Should have <= 3 results'
  end

  # Get projects listing searched.
  test 'get projects index searched' do
    get '/api/v1/projects?search=Media'
    assert_response :success
    resp = parse(response)
    assert resp.length == 1, 'Should have only got one result called Media Test'
    assert resp[0]['name'] == 'Media Test', 'Should have gotten project Media Test'
  end

  # Get project
  test 'get project' do

    get "/api/v1/projects/#{@test_proj.id}"
    assert_response :success
    assert keys_match(response, @project_keys), 'Keys are missing'
    assert parse(response)['id'] == @test_proj.id, "Should have returned project #{@test_proj.id}"
  end

  # Get project with owner/dataSets/mediaObjects
  test 'get project full' do
    get "/api/v1/projects/#{@test_proj.id}?recur=true"
    assert_response :success
    assert keys_match(response, @project_keys_extended), 'Keys are missing'
    assert parse(response)['id'] == @test_proj.id, "Should have returned project #{@test_proj.id}"
  end

  # Create project without giving a name
  test 'create project' do
    post '/api/v1/projects',

          email: 'kcarcia@cs.uml.edu',
          password: '12345'

    assert_response :success
    assert keys_match(response, @project_keys), 'Keys are missing'
  end

  # Create a named project
  test 'create project named' do
    post '/api/v1/projects',

          project_name: 'Awesome',
          email: 'kcarcia@cs.uml.edu',
          password: '12345'

    assert_response :success
    assert keys_match(response, @project_keys), 'Keys are missing'
    assert parse(response)['name'] == 'Awesome', 'Project should have been Awesome'
  end

  # Failed project creation because of unauthorized
  test 'failed create project' do
    assert_difference('Project.count', 0) do
      post '/api/v1/projects'
      assert_response :unauthorized
    end
  end

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

  test 'test second fields data is not trucated if longer than first fields' do
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

    assert data_uploaded[0]['21'] == '1', 'First point should be 1'
    assert data_uploaded[1]['21'] == '2', 'First point should be 2'
    assert data_uploaded[2]['21'] == '3', 'First point should be 3'
    assert data_uploaded[3]['21'] == '4', 'First point should be 4'
    assert data_uploaded[4]['21'] == '5', 'First point should be 5'
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
    assert parse(response)['error'][0] == 'Title has already been taken',
        'Message should have been: Title has already been taken'

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

  test 'create_media_object' do
    img_path = Rails.root.join('test', 'CSVs', 'nerdboy.jpg')
    file = Rack::Test::UploadedFile.new(img_path, 'image/jpeg')

    # Create a media object for a project
    post '/api/v1/media_objects',

         upload: file,
         email: 'kcarcia@cs.uml.edu',
         password: '12345',
         type: 'project',
         id: @dessert_project.id

    assert_response :success
    assert keys_match(response, @media_object_keys), 'Keys are missing.'

    # Get non recursive
    id = parse(response)['id']
    get "/api/v1/media_objects/#{id}"
    assert_response :success
    assert keys_match(response, @media_object_keys), 'Keys are missing'

    # Get recursive
    get "/api/v1/media_objects/#{id}?recur=true"
    assert_response :success
    assert keys_match(response, @media_object_keys_extended), 'Keys are missing'
  end

  test 'failed create media bad auth' do
    img_path = Rails.root.join('test', 'CSVs', 'nerdboy.jpg')
    file = Rack::Test::UploadedFile.new(img_path, 'image/jpeg')

    # Failed do to bad auth
    post '/api/v1/media_objects',
        upload: file,
        id: @dessert_project.id,
        type: 'project'

    assert_response :unauthorized
  end

  test 'failed create media bad id' do
    img_path = Rails.root.join('test', 'CSVs', 'nerdboy.jpg')
    file = Rack::Test::UploadedFile.new(img_path, 'image/jpeg')

    # Failed due to bad data
    post '/api/v1/media_objects',
         upload: file,
         email: 'kcarcia@cs.uml.edu',
         password: '12345',
         type: 'project',
         id: 3

    assert_response :unprocessable_entity
  end

  test 'failed create media bad type' do
    img_path = Rails.root.join('test', 'CSVs', 'nerdboy.jpg')
    file = Rack::Test::UploadedFile.new(img_path, 'image/jpeg')

    # Failed due to bad data
    post '/api/v1/media_objects',
         upload: file,
         email: 'kcarcia@cs.uml.edu',
         password: '12345',
         type: 'user',
         id: 3

    assert_response :unprocessable_entity
  end

  test 'create_media_object contribution_key' do
    img_path = Rails.root.join('test', 'CSVs', 'nerdboy.jpg')
    file = Rack::Test::UploadedFile.new(img_path, 'image/jpeg')

    # Create a media object for a project
    post '/api/v1/media_objects',
         upload: file,
         contribution_key: 'apple',
         contributor_name: 'Student 1',
         type: 'project',
         id: @dessert_project.id

    assert_response :success
    assert keys_match(response, @media_object_keys), 'Keys are missing.'
  end

  test 'create media object for data set with key' do
    pid = @dessert_project.id
    post "/api/v1/projects/#{pid}/jsonDataUpload",

          title: 'Data Set for Media Object',
          contribution_key: 'apple',
          contributor_name: 'Student 1',
          data:
            {
              '20' => ['1', '2', '3', '4', '5']
            }

    id = parse(response)['id']
    get "/api/v1/data_sets/#{id}"
    img_path = Rails.root.join('test', 'CSVs', 'nerdboy.jpg')
    file = Rack::Test::UploadedFile.new(img_path, 'image/jpeg')

    # Create a media object for a project
    post '/api/v1/media_objects',
         upload: file,
         contribution_key: 'apple',
         contributor_name: 'Student 1',
         type: 'data_set',
         id: id
    assert_response :success
    assert keys_match(response, @media_object_keys), 'Keys are missing.'
  end

  test 'failed create_media_object contribution_key' do
    img_path = Rails.root.join('test', 'CSVs', 'nerdboy.jpg')
    file = Rack::Test::UploadedFile.new(img_path, 'image/jpeg')

    # Create a media object for a project
    post '/api/v1/media_objects',
         upload: file,
         contribution_key: 'blueberry',
         contributor_name: 'Student 1',
         type: 'project',
         id: @dessert_project.id

    assert_response :unauthorized

  end

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
            'project_id' => id,
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

  test 'add a key that already exists' do
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
            'project_id' => id,
            'key' => 'key'
          }
    assert_response :created

    post "/api/v1/projects/#{id}/add_key",
        email: 'kcarcia@cs.uml.edu',
        password: '12345',
        contrib_key:
          {
            'name' => 'key_name',
            'project_id' => id,
            'key' => 'key'
          }
    assert_response :unprocessable_entity
  end

  private

  def parse(x)
    JSON.parse(x.body)
  end

  def keys_match(x, expected_keys)
    (JSON.parse(x.body).keys.map { |key| expected_keys.include? key }).uniq.length == 1
  end
end
