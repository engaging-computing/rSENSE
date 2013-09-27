require 'test_helper'

class FieldsControllerTest < ActionController::TestCase
  setup do
    @kate  = users(:kate)
    @field = fields(:one)
  end

  test "should show field" do
    get :show, { id: @field }, { user_id: @kate }
    assert_response :success
  end

 test "should get fields as json" do
    get :show, { format: 'json', id: @field }, { user_id: @kate }
    assert_response :success
  end

  test "should create field" do
    assert_difference('Field.count') do
      post :create, { field: { project_id: @field.project_id, field_type: @field.field_type, 
        name: "bacon", unit: @field.unit }}, { user_id: @kate }
    end

    assert_redirected_to field_path(assigns(:field))
  end

  test "should update field" do
    put :update, { id: @field, field: { project_id: @field.project_id, field_type: @field.field_type, 
      name: "pork rinds", unit: @field.unit }}, { user_id: @kate }
    assert_equal flash[:notice], "Field was successfully updated."
    assert_response :redirect
  end

  test "should update field and return json" do
    put :update, { format: 'json', id: @field, field: { project_id: @field.project_id, 
      field_type: @field.field_type, name: "doritos", unit: @field.unit }}, 
      { user_id: @kate }
    assert_response :success
  end

  test "should destroy field" do
    assert_difference('Field.count', -1) do
      delete :destroy, { id: @field }, { user_id: @kate }
    end

    assert_redirected_to fields_path
  end

  test "should destroy field from api" do
    assert_difference('Field.count', -1) do
      delete :destroy, { format: 'json', id: @field }, { user_id: @kate }
    end

    assert_response :success
  end

  test "should bulk update fields" do
    aa = Field.find(22)
    aa.name = "bork"

    post :updateFields, { format: 'json', id: @field.project.id, changes: [aa] }, 
      { user_id: @kate }
    assert_response :success
  end
end
