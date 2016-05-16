require 'test_helper'

class FieldsControllerTest < ActionController::TestCase
  setup do
    @field = fields(:one)
  end

  test 'should show field' do
    kate = sign_in('user', users(:kate))
    get :show, { id: @field },  user_id: kate
    assert_response :success
  end

  test 'should get fields as json' do
    kate = sign_in('user', users(:kate))
    get :show, { format: 'json', id: @field },  user_id: kate
    assert_response :success

    get :show, { format: 'json', id: @field, recur: true }, user_id: kate
    assert_response :success
    assert JSON.parse(response.body).key?('project'), 'to_hash should have returned the project'
  end

  test 'should create field' do
    kate = sign_in('user', users(:kate))
    assert_difference('Field.count') do
      post :create, { format: 'json', field: { project_id: @field.project_id, field_type: @field.field_type,
        name: 'bacon', unit: @field.unit } },  user_id: kate
    end

    assert_response :created
  end

  test 'should create field without name' do
    kate = sign_in('user', users(:kate))
    assert_difference('Field.count') do
      post :create, { format: 'json', field: { project_id: @field.project_id, field_type: @field.field_type } },  user_id: kate
    end
    assert_response :created
    assert JSON.parse(response.body)['name'] == 'Number', 'Should have created field with name NUMBER'

    assert_difference('Field.count') do
      post :create, { format: 'json', field: { project_id: @field.project_id, field_type: @field.field_type } },  user_id: kate
    end
    assert_response :created
    assert JSON.parse(response.body)['name'] == 'Number_2', 'Should have created field with name NUMBER_2'

    assert_difference('Field.count') do
      post :create, { format: 'json', field: { project_id: @field.project_id, field_type: @field.field_type } },  user_id: kate
    end
    assert_response :created
    assert JSON.parse(response.body)['name'] == 'Number_3', 'Should have created field with name NUMBER_3'
  end

  test 'should not create field' do
    kate = sign_in('user', users(:kate))
    assert_no_difference('Field.count') do
      post :create, { format: 'json', field: { project_id: @field.project_id } },  user_id: kate
    end

    assert_response :unprocessable_entity
  end

  test 'should update field' do
    kate = sign_in('user', users(:kate))
    put :update, { id: @field, field: { project_id: @field.project_id, field_type: @field.field_type,
      name: 'pork rinds', unit: @field.unit } },  user_id: kate
    assert_equal flash[:notice], 'Field was successfully updated.'
    assert_response :redirect
  end

  test 'should not update field' do
    kate = sign_in('user', users(:kate))
    id = @field.project_id
    put :update, { id: @field, field: { project_id: nil } },  user_id: kate
    put :update, { format: 'json', id: @field, field: { project_id: nil } },  user_id: kate
    assert_equal id, @field.project_id
  end

  test 'should update field and return json' do
    kate = sign_in('user', users(:kate))
    put :update, { format: 'json', id: @field, field: { project_id: @field.project_id,
      field_type: @field.field_type, name: 'doritos', unit: @field.unit } },
       user_id: kate
    assert_response :success
  end

  test 'should destroy field' do
    kate = sign_in('user', users(:kate))
    assert_difference('Field.count', -1) do
      delete :destroy, { id: @field },  user_id: kate
    end

    assert_redirected_to project_path(@field.project_id)
  end

  test 'should not destroy field' do
    crunch = sign_in('user', users(:crunch))
    assert_no_difference('Field.count', -1) do
      delete :destroy, { id: @field },  user_id: crunch
    end

    assert_no_difference('Field.count', -1) do
      crunch = sign_in('user', users(:crunch))
      delete :destroy, { format: 'json', id: @field },  user_id: crunch
    end
  end

  test 'should destroy field from api' do
    kate = sign_in('user', users(:kate))
    assert_difference('Field.count', -1) do
      delete :destroy, { format: 'json', id: @field },  user_id: kate
    end

    assert_response :success
  end

  test 'should add restrictions to text field' do
    kate = sign_in('user', users(:kate))
    post :update, { format: 'json', id: @field.id, field: { restrictions: ['a', 'b', 'c'] } },
       user_id: kate
    assert_response :success
  end
end
