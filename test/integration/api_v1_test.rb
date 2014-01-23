require 'test_helper'

class ApiV1Test < ActionDispatch::IntegrationTest
  setup do
    @project_keys = ['id','featuredMediaId','name','url','path','hidden','featured','likeCount','content','timeAgoInWords','createdAt','ownerName','ownerUrl','dataSetCount','fieldCount','fields']
    @project_keys_extended = @project_keys + ['dataSets','mediaObjects','owner']

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

  test "get projects index paged" do
    get '/api/v1/projects?per_page=3&page=2'
    assert_response :success
    assert parse(response).length <= 3, "Should have <= 3 results"
  end

  test "get project" do
    get '/api/v1/projects/1'
    assert_response :success
    assert keys_match(response), "Keys are missing"
    assert parse(response)['id'] == 1, 'Should have returned project 1'
  end

  test "get project full" do
    get '/api/v1/projects/1?recur=true'
    assert_response :success
    assert keys_match(response,true), "Keys are missing"
    assert parse(response)['id'] == 1, 'Should have returned project 1'
  end

  test "create project" do
    post "/api/v1/projects?auth_key=#{@auth_key}"
    assert_response :success
    assert keys_match(response), "Keys are missing"
  end

  test "create project named" do
    post "/api/v1/projects?auth_key=#{@auth_key}&project_name=Awesome"
    assert_response :success
    assert keys_match(response), "Keys are missing"
    assert parse(response)['name'] == "Awesome", "Project should have been Awesome"
  end
    
  def parse (x)
    JSON.parse(x.body)
  end

  def keys_match(x, extended = false)
    keys = extended ? @project_keys_extended : @project_keys
    (JSON.parse(x.body).keys.collect {|key| keys.include? key}).uniq.length ==1
  end
  
end