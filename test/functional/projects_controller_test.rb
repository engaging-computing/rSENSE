require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase
  setup do
    @project_one = projects(:one)
    @project_two = projects(:two)
    @project_three = projects(:three)
    @delete_me = projects(:delete_me)
    @delete_me_two = projects(:delete_me2)
    @delete_me_three = projects(:delete_me3)
    @delete_me_and_my_fields = projects(:delete_me_and_my_fields)
    @delete_me_field = fields(:delete_me)
    @key = contrib_keys(:contributor_key_test)
    @media_test = projects(:media_test)
    @dessert = projects(:dessert)
    @tag = tags(:one)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:projects)
    # HTML5 Validation is being skipped until the validator is fixed
    # assert_valid_html response.body
  end

  test 'should get index (json)' do
    get :index,  format: 'json'
    assert_response :success
    assert_not_nil assigns(:projects)
  end

  test 'should show project' do
    views_before = @project_one.views
    get :show,  id: @project_one
    assert_response :success
    # HTML5 Validation is being skipped until the validator is fixed
    # assert_valid_html response.body

    get :show, id: @project_two, format: 'json'
    assert_response :success

    @pp = Project.find(@project_one.id)
    assert @pp.views == views_before + 1, 'View count incremented'
  end

  test 'should show project (json)' do
    views_before = @project_one.views
    get :show,  format: 'json', id: @project_one
    assert_response :success

    @pp = Project.find(@project_one.id)
    assert @pp.views == views_before, 'View count not incremented'
  end

  test 'should create project' do
    nixon = sign_in('user', users(:nixon))
    assert_difference('Project.count') do
      post :create, { project: { content: @project_one.content, title: @project_one.title, user_id: @project_one.user_id } },
         user_id: nixon
    end

    assert_redirected_to project_path(assigns(:project))
  end

  test 'shouldnt create project' do
    kate = sign_in('user', users(:kate))
    post :create, { format: 'json', project: { title: '', user_id: kate } },
         user_id: kate
    assert_response :unprocessable_entity
  end

  test 'should create project (json)' do
    nixon = sign_in('user', users(:nixon))
    assert_difference('Project.count') do
      post :create, { format: 'json', project: { content: @project_one.content, title: @project_one.title,
        user_id: @project_one.user_id } },  user_id: nixon
    end
    post :create, { format: 'json', project_id: @project_two, project: { title: 'P2clone' } },  user_id: nixon
    assert_response :created
  end

  test 'should get edit' do
    nixon = sign_in('user', users(:nixon))
    get :edit, { id: @project_one },  user_id: nixon
    assert_response :success
    # HTML5 Validation is being skipped until the validator is fixed
    # assert_valid_html response.body
  end

  test 'should update project' do
    nixon = sign_in('user', users(:nixon))
    put :update, { id: @project_one, project: { content: @project_one.content, title: @project_one.title,
      user_id: @project_one.user_id } },  user_id: nixon
    assert_redirected_to project_path(assigns(:project))
  end

  test 'should update project (json)' do
    nixon = sign_in('user', users(:nixon))
    put :update, { format: 'json', id: @project_one, project: { content: @project_one.content, title: @project_one.title,
      user_id: @project_one.user_id } },  user_id: nixon
    assert_response :success
  end

  test 'should create project tag (json)' do
    nixon = sign_in('user', users(:nixon))
    post :create_tag, { format: 'json', id: @project_one, name: 'science' },  user_id: nixon
    assert_response :success
  end

  test 'should remove project tag (json)' do
    nixon = sign_in('user', users(:nixon))
    post :remove_tag, { format: 'json', id: @project_one, tagId: @tag },  user_id: nixon
    assert_response :success
  end

  test 'should hide project' do
    kate = sign_in('user', users(:kate))
    put :update, { format: 'json', id: @project_one, project: { hidden: true } },  user_id: kate
    assert_response :success
    assert Project.find(@project_one.id).hidden?, 'Project got hidden'
  end

  test 'should destroy project' do
    nixon = sign_in('user', users(:nixon))
    assert_difference('Project.count', -1) do
      delete :destroy, { id: @delete_me },  user_id: nixon
    end

    kate = sign_in('user', users(:kate))
    assert_difference('Project.count', -1) do
      delete :destroy, { id: @delete_me_two }, user_id: kate
    end

    assert_raises(ActiveRecord::RecordNotFound) do
      Project.find(@delete_me.id)
    end

    assert_redirected_to projects_path
  end

  test 'shouldnt destroy project' do
    @num_projects = Project.count
    kate = sign_in('user', users(:kate))
    delete :destroy, { format: 'json', id: @media_test }, user_id: kate
    assert_response :forbidden, "Kate shouldn't be able to delete this project"
    kate = sign_in('user', users(:kate))
    delete :destroy, { format: 'json', id: @project_one }, user_id: kate
    assert_response :forbidden, "Kate shouldn't be able to delete this project."
    nixon = sign_in('user', users(:nixon))
    delete :destroy, { format: 'json', id: @dessert }, user_id: nixon
    assert_response :forbidden, "Nixon shouldn't be able to delete this project."
  end

  test 'should destroy project (json)' do
    nixon = sign_in('user', users(:nixon))
    assert_difference('Project.count', -1) do
      delete :destroy, { format: 'json', id: @delete_me_three },  user_id: nixon
    end

    assert_raises(ActiveRecord::RecordNotFound) do
      Project.find(@delete_me_three.id)
    end

    assert_response :success
  end

  test 'should like project' do
    before = Project.find(@project_one).likes.count

    kate = sign_in('user', users(:kate))
    post :updateLikedStatus, { format: 'json', id: @project_one },  user_id: kate
    assert_response :success
    assert Project.find(@project_one).likes.count == before + 1, 'Like count should have increased by 1'

    post :updateLikedStatus, { format: 'json', id: @project_one },  user_id: kate
    assert_response :success
    assert Project.find(@project_one).likes.count == before, 'Like count should have decreased by 1'
    sign_out('user')

    post :updateLikedStatus, { format: 'json', id: @project_one },  user_id: 7
    assert_response 302, "Shouldn't be able to like a project if you aren't logged in"
    get :show,  format: 'json', id: @project_one
    assert_response :success
  end

  test 'should feature project (json)' do
    nixon = sign_in('user', users(:nixon))
    put :update, { format: 'json', id: @project_three, project: { featured: 'true' } },  user_id: nixon
    assert_response :success
    assert Project.find(@project_three).featured == true, 'Nixon should have featured the project'
    sign_out('user')

    kate = sign_in('user', users(:kate))
    put :update, { format: 'json', id: @project_three, project: { featured: 'false' } },  user_id: kate
    assert_response :ok
    assert Project.find(@project_three).featured == true, 'Kate should not have been able to unfeature the project.'
    sign_out('user')

    nixon = sign_in('user', users(:nixon))
    put :update, { format: 'json', id: @project_three, project: { featured: 'false' } }, user_id: nixon
    assert Project.find(@project_three).featured == false, 'Nixon should have unfeatured the project.'
  end

  test 'should curate project (json)' do
    nixon = sign_in('user', users(:nixon))
    put :update, { format: 'json', id: @project_three, project: { curated: 'true' } },  user_id: nixon
    assert_response :success
    project = Project.find(@project_three)
    assert project.curated == true, 'Nixon should have curated the project'
    assert project.lock == true, 'Curating should have locked the project'
    sign_out('user')

    kate = sign_in('user', users(:kate))
    put :update, { format: 'json', id: @project_three, project: { curated: 'false' } },  user_id: kate
    assert_response :ok
    assert Project.find(@project_three).curated == true, 'Kate should not have been able to uncurated the project'
    sign_out('user')

    crunch = sign_in('user', users(:crunch))
    put :update, { format: 'json', id: @project_three, project: { curated: 'false' } },  user_id: crunch
    assert_response :unprocessable_entity
    assert Project.find(@project_three).curated == true, 'Crunch should not have been able to uncurated the project'
    sign_out('user')

    nixon = sign_in('user', users(:nixon))
    put :update, { format: 'json', id: @project_three, project: { curated: 'false' } },  user_id: nixon
    assert_response :success
    assert Project.find(@project_three).curated == false, 'Nixon should have been able to uncurated the project'
  end

  test 'should lock project (json)' do
    nixon = sign_in('user', users(:nixon))
    put :update, { format: 'json', id: @project_three, project: { lock: 'true' } },  user_id: nixon
    assert_response :success, 'Nixon should have updated the project'
    assert Project.find(@project_three).lock == true, 'Nixon should have locked the project'
    sign_out('user')

    kate = sign_in('user', users(:kate))
    put :update, { format: 'json', id: @project_three, project: { lock: 'false' } },  user_id: kate
    assert_response :success
    assert Project.find(@project_three).lock == false, 'Kate should have unlocked the project'
    sign_out('user')

    crunch = sign_in('user', users(:crunch))
    put :update, { format: 'json', id: @project_three, project: { lock: 'true' } },  user_id: crunch
    assert_response :unprocessable_entity
    assert Project.find(@project_three).lock == false, 'Crunch should not have locked the project'
  end

  test 'should edit fields' do
    kate = sign_in('user', users(:kate))
    put :edit_fields, { id: @project_one }, user_id: kate
    assert_response :success
  end

  test 'save fields' do
    kate = sign_in('user', users(:kate))
    parameters = {}
    @dessert.fields.each do |field|
      parameters["#{field.id}_name"] = field.name
      parameters["#{field.id}_unit"] = field.unit
    end
    parameters['new_field'] = 'Location'
    parameters['user_id'] = users(:kate).id
    parameters['hidden_deleted_fields'] = ''

    # Adds a Latitude and Longitude field to determine where the dinner was eaten!
    post :save_fields, { id: @dessert.id, hidden_deleted_fields: '', field: { id: 23, project_id: @dessert.id, field_type: 4, name: 'Location of Foods' },
                        '20_name' => parameters['20_name'], '20_unit' => parameters['20_unit'], '21_name' => parameters['21_name'],
                        '21_unit' => parameters['21_unit'], '22_name' => parameters['22_name'], '22_unit' => parameters['22_unit'],
                        '23_name' => 'Location of Foods', '23_unit' => '', new_field: 'Location', format: 'json' }, user_id: kate
    body = JSON.parse(@response.body)
    assert_response :ok
    assert body.key?('redirect'), 'Response body does not contain redirect information'
    assert body['redirect'].include?("/projects/#{@dessert.id}"), 'Redirect is to wrong location'

    # No field added, cannot have two Lat fields, even with different names.
    assert_difference('Project.find(@dessert.id).fields.length', 0) do
      post :save_fields, { id: @dessert.id, hidden_deleted_fields: '', field: { id: 24, project_id: @dessert.id, field_type: 4, name: 'Location of Foodss' },
                          '20_name' => parameters['20_name'], '20_unit' => parameters['20_unit'], '21_name' => parameters['21_name'],
                          '21_unit' => parameters['21_unit'], '22_name' => parameters['22_name'], '22_unit' => parameters['22_unit'],
                          '24_name' => 'Location of Foodss', '24_unit' => '', new_field: 'Location', format: 'json' }, user_id: kate
    end

    @project = Project.find(@dessert.id)
    num_fields = @project.fields.length
    new_lat_field_id = @project.fields[num_fields - 2].id
    new_long_field_id = @project.fields[num_fields - 1].id

    # Tests empty value in restrictions hash
    post :save_fields, { id: @dessert.id, hidden_deleted_fields: '', field: { id: 25, project_id: @dessert.id, field_type: 3, name: 'Location of Foodz' },
                      '20_name' => parameters['20_name'], '20_unit' => parameters['20_unit'], '21_name' => parameters['21_name'],
                      '21_unit' => parameters['21_unit'], '22_name' => parameters['22_name'], '22_unit' => parameters['22_unit'],
                      "#{new_lat_field_id}_name" => @project.fields[num_fields - 2].name, "#{new_lat_field_id}_unit" => @project.fields[num_fields - 2].unit,
                      "#{new_long_field_id}_name" => @project.fields[num_fields - 1].name, "#{new_long_field_id}_unit" => @project.fields[num_fields - 1].unit,
                      '20_restrictions' => '',
                      '25_name' => 'Location of Foodz', '25_unit' => '', new_field: 'Latitude', format: :json }, user_id: kate
    body = JSON.parse(@response.body)
    assert_response :ok
    assert body.key?('redirect'), 'Response body does not contain redirect information'
    assert body['redirect'].include?("/projects/#{@dessert.id}"), 'Redirect is to wrong location'
  end

  test 'fields are destroyed along with project' do
    # Delete Project
    nixon = sign_in('user', users(:nixon))
    assert_difference('Project.count', -1) do
      delete :destroy, { id: @delete_me_and_my_fields },  user_id: nixon
    end

    # Test Project no longer exists
    assert_raises(ActiveRecord::RecordNotFound) do
      Project.find(@delete_me_and_my_fields.id)
    end

    # Test Project's field no longer exists either
    assert_raises(ActiveRecord::RecordNotFound) do
      Field.find(@delete_me_field.id)
    end
  end
end
