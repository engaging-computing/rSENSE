require 'test_helper'

class DataSetsControllerTest < ActionController::TestCase
  setup do
    @data_set = data_sets(:one)
    @tgd  = data_sets(:thanksgiving)
    @proj = @tgd.project
  end

  test 'redirect to vis for show data set' do
    get :show,  id: @tgd.id
    assert_response :redirect
  end

  test 'get data set data' do
    kate = sign_in('user', users(:kate))
    get :show, { id: @tgd.id, format: 'json', recur: 'true' },  user_id: kate
    assert_response :success
    ds = JSON.parse(@response.body)
    assert_equal 3, ds['data'][0].keys.length, 'Actually got records in data'
  end

  test 'create data_set' do
    kate = sign_in('user', users(:kate))
    assert_difference('DataSet.count') do
      post :create, { data_set: { project_id: @data_set.project_id,
        title: "#{@data_set.title}#{Time.now}", user_id: @data_set.user_id } },  user_id: kate
    end

    assert_redirected_to data_set_path(assigns(:data_set))
  end

  test 'should not create data_set in locked project' do
    crunch = sign_in('user', users(:crunch))
    assert_difference('DataSet.count', 0) do
      post :create, { data_set: { project_id: @tgd.project_id,
        title: "#{@tgd.title}#{Time.now}" } },  user_id: crunch
    end

    assert_response :redirect
    assert flash[:alert] =~ /locked/, 'Project is locked'
  end

  test 'create data_set with contrib key' do
    crunch = sign_in('user', users(:crunch))
    assert_difference('DataSet.count') do
      post :create, { data_set: { project_id: @tgd.project_id,
        title: "#{@tgd.title}#{Time.now}" } },
         user_id: crunch, contrib_access: @tgd.project.id
    end

    assert_redirected_to data_set_path(assigns(:data_set))
  end

  test 'create data_set with contrib key when not logged in' do
    assert_difference('DataSet.count') do
      post :create, { data_set: { project_id: @tgd.project_id,
        title: "#{@tgd.title}#{Time.now}" } },  contrib_access: @tgd.project.id
    end

    assert_redirected_to data_set_path(assigns(:data_set))
  end

  test 'create data_set and get JSON response' do
    kate = sign_in('user', users(:kate))
    title = "#{@data_set.title}#{Time.now}"
    assert_difference('DataSet.count') do
      post :create, { format: 'json', data_set: {
        project_id: @data_set.project_id, title: title,
        user_id: @data_set.user_id } },  user_id: kate
    end

    ds = JSON.parse(@response.body)
    assert_equal ds['name'], title, 'Actually saved data'

    assert_response :success
  end

  test 'show data_set edit page' do
    kate = sign_in('user', users(:kate))
    get :edit, { id: @tgd.id },  user_id: kate
    assert @response.body =~ /Thanksgiving/, 'Response has data_set title'
    assert_response :success
  end

  test 'update data_set' do
    kate = sign_in('user', users(:kate))
    put :update, { id: @data_set, data_set: { project_id: @data_set.project_id,
      title: @data_set.title, user_id: @data_set.user_id } },  user_id: kate
    assert_redirected_to data_set_path(assigns(:data_set))
  end

  test 'destroy data_set' do
    kate = sign_in('user', users(:kate))
    assert_difference('DataSet.count', -1) do
      delete :destroy, { id: @data_set },  user_id: kate
    end

    assert_response :redirect
  end

  test 'should not destroy data_set' do
    crunch = sign_in('user', users(:crunch))
    assert_difference('DataSet.count', 0) do
      delete :destroy, { id: @data_set },  user_id: crunch
    end

    assert_response :forbidden
  end

  test 'should not destroy data_set (json) ' do
    crunch = sign_in('user', users(:crunch))
    assert_difference('DataSet.count', 0) do
      delete :destroy, { format: 'json', id: @data_set },  user_id: crunch
    end
    assert_response :forbidden
  end

  test 'should not get manual entry page for locked project' do
    crunch = sign_in('user', users(:crunch))
    get :manualEntry, { id: @proj.id },  user_id: crunch
    assert_response :redirect
    assert flash[:alert] =~ /locked/, 'Project is locked'
  end

  test 'get manual entry page for locked project with key' do
    crunch = sign_in('user', users(:crunch))
    get :manualEntry, { id: @proj.id },  user_id: crunch, contrib_access: @proj.id
    assert_response :success
  end

  test 'get manual entry page' do
    kate = sign_in('user', users(:kate))
    get :manualEntry, { id: @proj.id },  user_id: kate
    assert_response :success
  end

  test 'export data' do
    kate = sign_in('user', users(:kate))
    get :export, { id: @proj.id, datasets: @tgd.id.to_s },  user_id: kate
    assert(@response['Content-Type'] == 'file/zip')
  end

  test 'get data as csv string' do
    kate = sign_in('user', users(:kate))
    get :export_concatenated, { id: @proj.id, datasets: @tgd.id.to_s },  user_id: kate
    assert response.body.include?('cookie,cake,pie'), 'Response was not correct string'
    assert_response :success
  end

  test 'upload CSV' do
    kate = sign_in('user', users(:kate))
    csv_path = Rails.root.join('test', 'CSVs', 'dinner.csv')
    file = Rack::Test::UploadedFile.new(csv_path, 'text/csv')
    post :dataFileUpload, { pid: @proj.id, file: file },  user_id: kate
    assert_response :success
  end

  test 'upload through jsonDataUpload' do
    kate = sign_in('user', users(:kate))
    post :jsonDataUpload, { format: 'json', id: @proj.id, title: 'JSON Upload',
      data: { '20' => ['1', '2', '3'], '21' => ['4', '5', '6'], '22' => ['14', '13', '12'] } },  user_id: kate
    assert_response :success
    @new_dataset_id = JSON.parse(response.body)['id']
  end

  test 'should fail jsonDataUpload with empty data set' do
    kate = sign_in('user', users(:kate))
    post :jsonDataUpload, { format: 'json', id: @proj.id, title: 'JSON Upload',
      data: {} },  user_id: kate
    assert_response 422
  end

  test 'should not jsonDataUpload for locked project' do
    crunch = sign_in('user', users(:crunch))
    post :jsonDataUpload, { format: 'json', id: @proj.id, title: 'JSON Upload',
      data: { '20' => ['1', '2', '3'], '21' => ['4', '5', '6'], '22' => ['14', '13', '12'] } },  user_id: crunch
    assert_response 401
  end

  test 'jsonDataUpload locked project with key' do
    crunch = sign_in('user', users(:crunch))
    post :jsonDataUpload, { format: 'json', id: @proj.id, title: 'JSON Upload',
      data: { '20' => ['1', '2', '3'], '21' => ['4', '5', '6'], '22' => ['14', '13', '12'] } },
      user_id: crunch, contrib_access: @proj.id
    assert_response :success
    @new_dataset_id = JSON.parse(response.body)['id']
  end

  test 'jsonDataUpload locked project with key not logged in' do
    post :jsonDataUpload, { format: 'json', id: @proj.id, title: 'JSON Upload',
      data: { '20' => ['1', '2', '3'], '21' => ['4', '5', '6'], '22' => ['14', '13', '12'] } },
       contrib_access: @proj.id,
       contributor_name: 'Kate C.'
    assert_response :success
    @new_dataset_id = JSON.parse(response.body)['id']
  end

  test 'edit data set' do
    kate = sign_in('user', users(:kate))
    # Get original data
    get :show, { id: @tgd.id, format: 'json', recur: 'true' },  user_id: kate
    assert_response :success
    ds = JSON.parse(@response.body)
    original_data = ds['data']
    original_row_count = ds['data'].length

    # Edit the data and commit
    new_data = { '20' => ['1', '2', '3'], '21' => ['4', '5', '6'], '22' => ['14', '13', '12'] }
    post :edit, { id: @tgd.id, format: 'json', data: new_data }, user_id: kate
    assert_response :success

    # Get data afer commit to check
    get :show, { id: @tgd.id, format: 'json', recur: 'true' },  user_id: kate
    assert_response :success
    ds = JSON.parse(@response.body)
    assert ds['data'] != original_data, 'Data has not changed after editing'
    assert ds['data'].length != original_row_count, 'Data same length as before editing'
  end

  test 'should fail to edit data set in locked project' do
    kate = sign_in('user', users(:kate))
    dataset = data_sets(:kates_dataset_in_locked_project)
    new_data = { '26' => ['1', '2', '3'] }
    post :edit, { id: dataset.id, format: 'json', data: new_data }, user_id: kate
    assert_redirected_to dataset.project, 'Should have failed to edit and get redirected to project page'
  end
end
