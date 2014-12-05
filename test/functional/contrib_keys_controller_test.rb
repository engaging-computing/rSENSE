require 'test_helper'

class ContribKeysControllerTest < ActionController::TestCase
  setup do
    @kate = users(:kate)
    @proj = projects(:one)
    @skey = contrib_keys(:one)
    @crunch = users(:crunch)
  end

  test 'should create contrib key' do
    assert_difference('ContribKey.count') do
      post :create, { contrib_key: { project_id: @proj.id, name: 'Pie', key: 'Pecan' } },  user_id: @kate.id
    end
    assert_response :redirect
  end

  test 'should not create contrib key' do
    assert_difference('ContribKey.count', 0) do
      post :create, { contrib_key: { project_id: @proj.id, name: 'Pie', key: 'Pecan' } },  user_id: @crunch.id
    end
    assert_response :redirect
  end

  test 'should destroy key' do
    assert_difference('ContribKey.count', -1) do
      post :destroy, { id: @skey.id },  user_id: @kate.id
    end
    assert_response :redirect
  end

  test 'should not destroy key' do
    assert_difference('ContribKey.count', 0) do
      post :destroy, { id: @skey.id },  user_id: @crunch.id
    end
    assert_response :redirect
  end

  test 'should enter key' do
    post :enter,  project_id: @proj.id, key: @skey.key, contributor_name: @kate.name
    assert_response :redirect
    assert_equal @proj.id, session[:contrib_access]
  end

  test 'bad key should fail' do
    post :enter,  project_id: @proj.id, key: 'password1'
    assert_response :redirect
    assert_not_nil flash[:error]
  end

  test 'missing key should fail' do
    post :enter,  project_id: @proj.id, key: ''
    assert_response :redirect
    assert_not_nil flash[:error]
  end
end
