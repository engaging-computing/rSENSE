require 'test_helper'

class DataSetsControllerTest < ActionController::TestCase
  setup do
    Dir.mkdir("/tmp/html_validation")
    @kate = users(:kate)
    @data_set = data_sets(:one)
    @tgd  = data_sets(:thanksgiving)
    @proj = @tgd.project
  end

 teardown do
   FileUtils.rm_rf("/tmp/html_validation")
 end
  
  test "should redirect to viz for show data set" do
    get :show, { id: @tgd.id }
    assert_response :redirect 
  end
 
  test "should get dataset data" do
    get :show, { id: @tgd.id, format: 'json', recur: 'true' }, { user_id: @kate }
    assert_response :success
    ds = JSON.parse(@response.body)
    assert_equal 3, ds['data'][0].keys.length, "Actually got records in data"
    
    # HTML validation
    assert_valid_html(request.body, "Data Set Data Get")
  end

  test "should create data_set" do
    assert_difference('DataSet.count') do
      post :create, { data_set: { content: @data_set.content, project_id: @data_set.project_id, 
        title: "#{@data_set.title}#{Time.now().to_s}", user_id: @data_set.user_id }}, { user_id: @kate }
    end

    assert_redirected_to data_set_path(assigns(:data_set))
  end

  test "should create data_set and get JSON response" do
    title = "#{@data_set.title}#{Time.now().to_s}"
    assert_difference('DataSet.count') do
      post :create, { format: 'json', data_set: { content: @data_set.content, 
        project_id: @data_set.project_id, title: title, 
        user_id: @data_set.user_id }}, { user_id: @kate }
    end

    ds = JSON.parse(@response.body)
    assert_equal ds['name'], title, "Actually saved data"

    assert_response :success
  end

  test "should show data_set edit page" do
    get :edit, { id: @tgd.id }, { user_id: @kate }
    assert @response.body =~ /Thanksgiving/, "Response has data_set title"
    assert_response :success
    
    # HTML validation
    assert_valid_html(request.body, "Data Set Edit Page Show")
  end

  test "should update data_set" do
    put :update, { id: @data_set, data_set: { content: @data_set.content, project_id: @data_set.project_id, 
      title: @data_set.title, user_id: @data_set.user_id }}, { user_id: @kate }
    assert_redirected_to data_set_path(assigns(:data_set))
  end

  test "should destroy data_set" do
    assert_difference('DataSet.count', -1) do
      delete :destroy, { id: @data_set }, { user_id: @kate }
    end

    assert_response :redirect
  end

  test "should get manual entry page" do
    get :manualEntry, { id: @proj.id }, { user_id: @kate }
    assert_response :success
    
    # HTML validation
    assert_valid_html(request.body, "Manual Entry Page Get")
  end

  test "should upload data set" do
    # headers tell you the order of the fields
    # the index of the header is the key for the field
    post :manualUpload, { format: 'json', id: @proj.id, headers: ["20", "21", "22"], 
      data: {"0" => ["1", "2", "3"], "1"=>["4", "5", "6"], "2" => ["14", "13", "12"]} }, { user_id: @kate }
    assert_response :success
    
    # HTML validation
    assert_valid_html(request.body, "Upload Data Set")
  end 

  test "should export data" do
    
    get :export, { id: @proj.id, datasets: "#{@data_set.id}"}, { user_id: @kate }
    assert(@response["Content-Type"] == "file/zip")
  end

  test "should upload CSV" do 
    csv_path = Rails.root.join('test', 'CSVs', 'dinner.csv')
    file = Rack::Test::UploadedFile.new(csv_path, "text/csv")
    post :dataFileUpload, { pid: @proj.id, file: file }, { user_id: @kate }
    assert_response :success
  end
end
