require 'test_helper'
require_relative 'api_v1_test'

class ApiV1MediaObjectsTest < ApiV1Test
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

  test 'failed create non-image media object' do
    img_path = Rails.root.join('test', 'CSVs', 'test.txt')
    file = Rack::Test::UploadedFile.new(img_path, 'text/plain')

    # Create a media object for a project
    post '/api/v1/media_objects',

         upload: file,
         email: 'kcarcia@cs.uml.edu',
         password: '12345',
         type: 'project',
         id: @dessert_project.id

    assert_response :unprocessable_entity
    assert parse(response).key?('error')
    assert parse(response)['error'] == 'API only supports images'
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

  test 'failed create media wrong auth for data set' do
    img_path = Rails.root.join('test', 'CSVs', 'nerdboy.jpg')
    file = Rack::Test::UploadedFile.new(img_path, 'image/jpeg')

    post '/api/v1/media_objects',
        upload: file,
        email: 'boxes@boxes.boxes',
        password: '12345',
        id: @thanksgiving_dataset.id,
        type: 'data_set'

    assert_response :unprocessable_entity
  end

  test 'failed create media wrong auth for project' do
    img_path = Rails.root.join('test', 'CSVs', 'nerdboy.jpg')
    file = Rack::Test::UploadedFile.new(img_path, 'image/jpeg')

    post '/api/v1/media_objects',
        upload: file,
        email: 'boxes@boxes.boxes',
        password: '12345',
        id: @dessert_project.id,
        type: 'project'

    assert_response :unprocessable_entity
  end

  # Don't run me yet:
  # test 'fialed create media long name' do
  #   img_path = Rails.root.join('test', 'CSVs', "nerdboy-long-name-#{'w' * 160}.jpg")
  #   file = Rack::Test::UploadedFile.new(img_path, 'image/jpeg')
  #   post '/api/v1/media_objects',
  #       upload: file,
  #       email: 'kcarcia@cs.uml.edu',
  #       password: '12345',
  #       id: @dessert_project.id,
  #       type: 'project'
  # 
  #   assert_response :unprocessable_entity
  # end

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
end
