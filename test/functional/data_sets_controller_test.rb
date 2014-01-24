require 'test_helper'

class DataSetsControllerTest < ActionController::TestCase
  setup do
    @kate = users(:kate)
    @data_set = data_sets(:one)
    @tgd  = data_sets(:thanksgiving)
    @proj = @tgd.project
    @crunch = users(:crunch)
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

  test "should not destroy data_set" do
    assert_difference('DataSet.count', 0) do
      delete :destroy, { id: @data_set }, { user_id: @crunch }
    end

    assert_response :forbidden
  end

  test "should not destroy data_set (json) " do
    assert_difference('DataSet.count', 0) do
      delete :destroy, {format: 'json', id: @data_set }, { user_id: @crunch }
    end
    assert_response :forbidden
  end

  test "should get manual entry page" do
    get :manualEntry, { id: @proj.id }, { user_id: @kate }
    assert_response :success
  end

  test "should export data" do
    get :export, { id: @proj.id, datasets: @tgd.id.to_s}, { user_id: @kate }
    assert(@response["Content-Type"] == "file/zip")
  end

  test "should upload CSV" do
    csv_path = Rails.root.join('test', 'CSVs', 'dinner.csv')
    file = Rack::Test::UploadedFile.new(csv_path, "text/csv")
    post :dataFileUpload, { pid: @proj.id, file: file }, { user_id: @kate }
    assert_response :success
  end

  test "should upload through jsonDataUpload" do
    post :jsonDataUpload, { format: 'json', id: @proj.id, title: "JSON Upload",
      data: {"20" => ["1", "2", "3"], "21"=>["4", "5", "6"], "22" => ["14", "13", "12"]} }, { user_id: @kate }
    assert_response :success
    @new_dataset_id = JSON.parse(response.body)['id']
  end

  test "should edit data set" do
    #Get original data
    get :show, { id: @tgd.id, format: 'json', recur: 'true' }, { user_id: @kate }
    assert_response :success
    ds = JSON.parse(@response.body)
    original_data = ds['data']
    original_row_count = ds['data'].length

    #Edit the data and commit
    new_data = {"20" => ["1", "2", "3"], "21"=>["4", "5", "6"], "22" => ["14", "13", "12"]}
    post :edit, {id: @tgd.id, format: 'json', data: new_data}, {user_id: @kate}
    assert_response :success

    #Get data afer commit to check
    get :show, { id: @tgd.id, format: 'json', recur: 'true' }, { user_id: @kate }
    assert_response :success
    ds = JSON.parse(@response.body)
    assert ds['data'] != original_data, "Data has not changed after editing"
    assert ds['data'].length != original_row_count, "Data same length as before editing"
  end
  
end
