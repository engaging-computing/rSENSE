require 'test_helper'

class FieldsControllerTest < ActionController::TestCase
  setup do
    @kate  = users(:kate)
    @field = fields(:one)
  end

  test "should create field" do
    assert_difference('Field.count') do
      post :create, { field: { project_id: @field.project_id, field_type: @field.field_type, 
        name: @field.name, unit: @field.unit }}, { user_id: @kate }
    end

    assert_redirected_to field_path(assigns(:field))
  end

  test "should show field" do
    get :show, { id: @field }, { user_id: @kate }
    assert_response :success
  end

  test "should update field" do
    put :update, { id: @field, field: { project_id: @field.project_id, field_type: @field.field_type, 
      name: @field.name, unit: @field.unit }}, { user_id: @kate }
    assert_response :redirect
  end

  test "should destroy field" do
    assert_difference('Field.count', -1) do
      delete :destroy, { id: @field }, { user_id: @kate }
    end

    assert_redirected_to fields_path
  end
end
