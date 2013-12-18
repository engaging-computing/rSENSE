require 'test_helper'

class StudentKeysControllerTest < ActionController::TestCase
  setup do
    @kate = users(:kate)
    @proj = projects(:one)
    @skey = student_keys(:one)
  end

  test "should create student key" do
    assert_difference('StudentKey.count') do
      post :create, { student_key: { project_id: @proj.id, name: "Pie", key: "Pecan" }}, { user_id: @kate.id }
    end
    assert_response :redirect
  end

  test "should destroy key" do
    assert_difference('StudentKey.count', -1) do
      post :destroy, { id: @skey.id }, { user_id: @kate.id }  
    end
    assert_response :redirect
  end

  test "should enter key" do
    post :enter, { project_id: @proj.id, key: @skey.key }
    assert_response :redirect
    assert_equal @proj.id, session[:student_access]
  end

  test "bad key should fail" do
    post :enter, { project_id: @proj.id, key: "password1" }
    assert_response :redirect
    assert_not_nil flash[:error]
  end
end
