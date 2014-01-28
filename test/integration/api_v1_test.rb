require 'test_helper'

class ApiV1Test < ActionDispatch::IntegrationTest
  setup do
    @project_keys = ['id','featuredMediaId','name','url','path','hidden','featured','likeCount','content','timeAgoInWords','createdAt','ownerName','ownerUrl','dataSetCount','fieldCount','fields']
    @project_keys_extended = @project_keys + ['dataSets','mediaObjects','owner']
    @field_keys = ['id','name','type','unit','restrictions']
    @data_keys = ['id','name','hidden','url','path','createdAt','fieldCount','datapointCount','displayURL']
    @data_keys_extended = @data_keys + ['owner','project','fields','data']
    @dessert_project = projects(:dessert)
    
    #get auth key for things that require it
    post '/api/v1/login?email=kcarcia%40cs%2Euml%2Eedu&password=12345'
    @auth_key = CGI::escape(parse(response)['authenticity_token'])
  end
  
  test "login" do
    post '/api/v1/login?email=kcarcia%40cs%2Euml%2Eedu&password=12345'
    assert_response :success
  end

  test "login fail" do
    post '/api/v1/login?email=kcarcia%40cs%2Euml%2Eedu&password=1234'
    assert_response :unauthorized
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
    cur = resp[0]['createdAt']
    resp.each do |p|
        assert p['createdAt'] <= cur, "Results not in DESC order"
        cur = p['createdAt']
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
    post "/api/v1/projects?auth_key=#{@auth_key}"
    assert_response :success
    assert keys_match(response, @project_keys), "Keys are missing"
  end

  test "create project named" do
    post "/api/v1/projects?auth_key=#{@auth_key}&project_name=Awesome"
    assert_response :success
    assert keys_match(response, @project_keys), "Keys are missing"
    assert parse(response)['name'] == "Awesome", "Project should have been Awesome"
  end

  test "create fields" do
    post "/api/v1/projects?auth_key=#{@auth_key}"
    assert_response :success
    id = parse(response)['id']
    
    post "/api/v1/fields?auth_key=#{@auth_key}&field[project_id]=#{id}&field[field_type]=1"
    assert_response :success
    assert keys_match(response, @field_keys), "Keys are missing"
  end
    
  test "create fields named" do
    post "/api/v1/projects?auth_key=#{@auth_key}"
    assert_response :success
    id = parse(response)['id']
    
    post "/api/v1/fields?auth_key=#{@auth_key}&field[name]=Fieldy&field[project_id]=#{id}&field[field_type]=1"
    assert_response :success
    assert keys_match(response, @field_keys), "Keys are missing"
  end
  
  test "create fields with restrictions" do
    post "/api/v1/projects?auth_key=#{@auth_key}"
    assert_response :success
    id = parse(response)['id']
    
    post "/api/v1/fields?auth_key=#{@auth_key}&field[name]=Fieldy&field[project_id]=#{id}&field[field_type]=1&field[restrictions]=x,y,z"
    assert_response :success
    assert keys_match(response, @field_keys), "Keys are missing"
  end
  
  test "get field" do
    get "/api/v1/fields/20"
    assert_response :success
    assert keys_match(response, @field_keys), "Keys are missing"
  end
  
  test "create data set" do
    pid = @dessert_project.id
    post "/api/v1/uploadDataSet?auth_key=#{@auth_key}&id=#{pid}&data[20][]=2&data[20][]=3&title=AwesomeData"
    assert_response :success
    assert keys_match(response, @data_keys), "Keys are missing"
    
    id = parse(response)['id']
    get "/api/v1/data_sets/#{id}?recur=true"
    assert_response :success
    assert keys_match(response, @data_keys_extended), "Keys are missing"
  end
  
  private
  def parse (x)
    JSON.parse(x.body)
  end

  def keys_match(x, expected_keys)
    (JSON.parse(x.body).keys.collect {|key| expected_keys.include? key}).uniq.length ==1
  end
  
end