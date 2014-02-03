require 'test_helper'

class ApiV1Test < ActionDispatch::IntegrationTest
  setup do
    @project_keys = ['id','featuredMediaId','name','url','path','hidden','featured','likeCount','content','timeAgoInWords','createdAt','ownerName','ownerUrl','dataSetCount','fieldCount','fields']
    @project_keys_extended = @project_keys + ['dataSets','mediaObjects','owner']
    @field_keys = ['id','name','type','unit','restrictions']
    @data_keys = ['id','name','hidden','url','path','createdAt','fieldCount','datapointCount','displayURL']
    @data_keys_extended = @data_keys + ['owner','project','fields','data']
    @dessert_project = projects(:dessert)
  end

  test "get projects index" do
    get '/api/v1/projects'
    assert_response :success
    assert parse(response).class == Array, "Response should be an array"
  end

  test "get projects sorted and ordered" do
    get '/api/v1/projects?sort=created_at&order=DESC'
    assert_response :success
    resp = parse(response)
    cur = Date.parse(resp[0]['createdAt'])
    resp.each do |p|
      next_date = Date.parse(p['createdAt'])
        assert next_date <= cur, "Results not in DESC order"
        cur = next_date
    end
  end

  test "get projects index paged" do
    get '/api/v1/projects?per_page=3&page=2'
    assert_response :success
    assert parse(response).length <= 3, "Should have <= 3 results"
  end

  test "get project" do
    get '/api/v1/projects/1'
    assert_response :success
    assert keys_match(response, @project_keys), "Keys are missing"
    assert parse(response)['id'] == 1, 'Should have returned project 1'
  end

  test "get project full" do
    get '/api/v1/projects/1?recur=true'
    assert_response :success
    assert keys_match(response, @project_keys_extended), "Keys are missing"
    assert parse(response)['id'] == 1, 'Should have returned project 1'
  end

  test "create project" do
    post "/api/v1/projects?email=kcarcia%40cs%2Euml%2Eedu&password=12345"
    assert_response :success
    assert keys_match(response, @project_keys), "Keys are missing"
  end

  test "failed create project" do
    assert_difference('Project.count',0) do
      post "/api/v1/projects?"
      assert_response :unauthorized
    end
  end

  test "create project named" do
    post "/api/v1/projects?project_name=Awesome&email=kcarcia%40cs%2Euml%2Eedu&password=12345"
    assert_response :success
    assert keys_match(response, @project_keys), "Keys are missing"
    assert parse(response)['name'] == "Awesome", "Project should have been Awesome"
  end

  test "create fields" do
    post "/api/v1/projects?email=kcarcia%40cs%2Euml%2Eedu&password=12345"
    assert_response :success
    id = parse(response)['id']

    post "/api/v1/fields?field[project_id]=#{id}&field[field_type]=1&email=kcarcia%40cs%2Euml%2Eedu&password=12345"
    assert_response :success
    assert keys_match(response, @field_keys), "Keys are missing"
  end

  test "create fields named" do
    post "/api/v1/projects?email=kcarcia%40cs%2Euml%2Eedu&password=12345"
    assert_response :success
    id = parse(response)['id']

    post "/api/v1/fields?field[name]=Fieldy&field[project_id]=#{id}&field[field_type]=1&email=kcarcia%40cs%2Euml%2Eedu&password=12345"
    assert_response :success
    assert keys_match(response, @field_keys), "Keys are missing"
  end

  test "create fields with restrictions" do
    post "/api/v1/projects?email=kcarcia%40cs%2Euml%2Eedu&password=12345"
    assert_response :success
    id = parse(response)['id']

    post "/api/v1/fields?field[name]=Fieldy&field[project_id]=#{id}&field[field_type]=1&field[restrictions]=x,y,z&email=kcarcia%40cs%2Euml%2Eedu&password=12345"
    assert_response :success
    assert keys_match(response, @field_keys), "Keys are missing"
  end

  test "failed create fields" do
    post "/api/v1/projects?email=kcarcia%40cs%2Euml%2Eedu&password=12345"
    assert_response :success
    id = parse(response)['id']
    assert_difference('Field.count',0) do
      post "/api/v1/fields?field[name]=Fieldy&field[project_id]=#{id}&field[field_type]=1&field[restrictions]=x,y,z"
      assert_response :unauthorized
    end
  end

  test "get field" do
    get "/api/v1/fields/20"
    assert_response :success
    assert keys_match(response, @field_keys), "Keys are missing"
  end
  
  test "create data set" do
    pid = @dessert_project.id
    post "/api/v1/projects/#{pid}/jsonDataUpload?data[20][]=2&data[20][]=3&title=AwesomeData&email=kcarcia%40cs%2Euml%2Eedu&password=12345"
    assert_response :success
    assert keys_match(response, @data_keys), "Keys are missing"

    id = parse(response)['id']
    get "/api/v1/data_sets/#{id}?recur=true"
    assert_response :success
    assert keys_match(response, @data_keys_extended), "Keys are missing"
  end

  test "failed create data set" do
    assert_difference('DataSet.count',0) do
      pid = @dessert_project.id
      post "/api/v1/projects/#{pid}/jsonDataUpload?data[20][]=2&data[20][]=3&title=AwesomeData"
      assert_response :unauthorized
    end
  end

  test "edit data set" do
    dset_id = @dessert_project.data_sets.first.id

    get "/api/v1/data_sets/#{dset_id}?recur=true"
    assert_response :success
    old_data = parse(response)['data']

    get "/api/v1/data_sets/#{dset_id}/edit?data[20][]=5&data[21][]=6&data[22][]=7&email=kcarcia%40cs%2Euml%2Eedu&password=12345"
    assert_response :success

    get "/api/v1/data_sets/#{dset_id}?recur=true"
    assert_response :success
    new_data = parse(response)['data']

    assert new_data != old_data, "Data didnt get updated"
    assert new_data[0]['20'] == '5', "First point should have been updated to 5"

  end
  
  test "failed edit data set" do
    dset_id = @dessert_project.data_sets.first.id

    get "/api/v1/data_sets/#{dset_id}?recur=true"
    assert_response :success
    old_data = parse(response)['data']

    get "/api/v1/data_sets/#{dset_id}/edit?data[20][]=5&data[21][]=6&data[22][]=7"
    assert_response :unauthorized

    get "/api/v1/data_sets/#{dset_id}?recur=true"
    assert_response :success
    new_data = parse(response)['data']

    assert new_data == old_data, "Data didnt get updated"

  end
  
  private
  def parse (x)
    JSON.parse(x.body)
  end

  def keys_match(x, expected_keys)
    (JSON.parse(x.body).keys.collect {|key| expected_keys.include? key}).uniq.length ==1
  end
  
end