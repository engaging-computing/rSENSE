require 'test_helper'

class DataSetsControllerTest < ActionController::TestCase
  setup do
    @kate = users(:kate)
    @data_set = data_sets(:one)
    @tgd = data_sets(:thanksgiving)
   end

  test "should create data_set" do
    assert_difference('DataSet.count') do
      post :create, { data_set: { content: @data_set.content, project_id: @data_set.project_id, 
        title: @data_set.title, user_id: @data_set.user_id }}, { user_id: @kate }
    end

    assert_redirected_to data_set_path(assigns(:data_set))
  end

  test "should update data_set" do
    put :update, { id: @data_set, data_set: { content: @data_set.content, project_id: @data_set.project_id, 
      title: @data_set.title, user_id: @data_set.user_id }}, { user_id: @kate }
    assert_redirected_to data_set_path(assigns(:data_set))
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

  test "should destroy data_set" do
    assert_difference('DataSet.count', 0) do
      delete :destroy, { id: @data_set }, { user_id: @kate }
    end

    @d0 = DataSet.find(@data_set.id)
    assert @d0.hidden

    assert_response :redirect
  end
end
