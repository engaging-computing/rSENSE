require 'test_helper'
require_relative 'api_v1_test'

class ApiV1ProjectsTest < ApiV1Test
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

  test 'create autonamed project' do
    post '/api/v1/projects',

      email: 'boxes@boxes.boxes',
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
  test 'failed create project unauthorized' do
    assert_difference('Project.count', 0) do
      post '/api/v1/projects'
      assert_response :unauthorized
    end
  end

  # Failed project creation because project name is way too long
  test 'failed create project long name' do
    assert_difference('Project.count', 0) do
      post '/api/v1/projects',

        project_name: 'W' * 999,
        email: 'kcarcia@cs.uml.edu',
        password: '12345'

      assert_response :unprocessable_entity
    end
  end
end
