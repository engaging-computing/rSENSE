require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase
  setup do
    @nixon   = users(:nixon)
    @kate    = users(:kate)
    @crunch  = users(:crunch)
    @project_one = projects(:one)
    @project_three = projects(:three)
    @delete_me = projects(:delete_me)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:projects)
    assert_valid_html response.body
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
    # FIXME
    # assert_valid_html response.body

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
    assert_difference('Project.count') do
      post :create, { project: { content: @project_one.content, title: @project_one.title, user_id: @project_one.user_id } },
         user_id: @nixon
    end

    assert_redirected_to project_path(assigns(:project))
  end

  test 'should create project (json)' do
    assert_difference('Project.count') do
      post :create, { format: 'json', project: { content: @project_one.content, title: @project_one.title,
        user_id: @project_one.user_id } },  user_id: @nixon
    end

    assert_response :success
  end

  test 'should get edit' do
    get :edit, { id: @project_one },  user_id: @nixon
    assert_response :success
    assert_valid_html response.body
  end

  test 'should update project' do
    put :update, { id: @project_one, project: { content: @project_one.content, title: @project_one.title,
      user_id: @project_one.user_id } },  user_id: @nixon
    assert_redirected_to project_path(assigns(:project))
  end

  test 'should update project (json)' do
    put :update, { format: 'json', id: @project_one, project: { content: @project_one.content, title: @project_one.title,
      user_id: @project_one.user_id } },  user_id: @nixon
    assert_response :success
  end

  test 'should hide project' do
    put :update, { format: 'json', id: @project_one, project: { hidden: true } },  user_id: @kate
    assert_response :success
    assert Project.find(@project_one.id).hidden?, 'Project got hidden'
  end

  test 'should destroy project' do
    assert_difference('Project.count', 0) do
      delete :destroy, { id: @delete_me },  user_id: @nixon
    end

    @p0 = Project.find(@delete_me.id)
    assert @p0.hidden, 'Project Got Hidden'

    assert_redirected_to projects_path
  end

  test 'should destroy project (json)' do
    assert_difference('Project.count', 0) do
      delete :destroy, { format: 'json', id: @delete_me },  user_id: @nixon
    end

    @p0 = Project.find(@delete_me.id)
    assert @p0.hidden, 'Project Got Hidden'

    assert_response :success
  end

  test 'should like project' do
    before = Project.find(@project_one).likes.count

    post :updateLikedStatus, { format: 'json', id: @project_one },  user_id: @kate
    assert_response :success
    assert Project.find(@project_one).likes.count == before + 1, 'Like count should have increased by 1'

    post :updateLikedStatus, { format: 'json', id: @project_one },  user_id: @kate
    assert_response :success
    assert Project.find(@project_one).likes.count == before, 'Like count should have decreased by 1'
  end

  test 'should feature project (json)' do
    put :update, { format: 'json', id: @project_three, project: { featured: 'true' } },  user_id: @nixon
    assert_response :success
    assert Project.find(@project_three).featured == true, 'Nixon should have featured the project'

    put :update, { format: 'json', id: @project_three, project: { featured: 'false' } },  user_id: @kate
    assert_response :ok
    assert Project.find(@project_three).featured == true, 'Kate should not have been able to unfeature the project.'
  end

  test 'should curate project (json)' do
    put :update, { format: 'json', id: @project_three, project: { curated: 'true' } },  user_id: @nixon
    assert_response :success
    project = Project.find(@project_three)
    assert project.curated == true, 'Nixon should have curated the project'
    assert project.lock == true, 'Curating should have locked the project'

    put :update, { format: 'json', id: @project_three, project: { curated: 'false' } },  user_id: @kate
    assert_response :ok
    assert Project.find(@project_three).curated == true, 'Kate should not have been able to uncurated the project'

    put :update, { format: 'json', id: @project_three, project: { curated: 'false' } },  user_id: @crunch
    assert_response :unprocessable_entity
    assert Project.find(@project_three).curated == true, 'Crunch should not have been able to uncurated the project'

    put :update, { format: 'json', id: @project_three, project: { curated: 'false' } },  user_id: @nixon
    assert_response :success
    assert Project.find(@project_three).curated == false, 'Nixon should have been able to uncurated the project'

  end

  test 'should lock project (json)' do
    put :update, { format: 'json', id: @project_three, project: { lock: 'true' } },  user_id: @nixon
    assert_response :success
    assert Project.find(@project_three).lock == true, 'Nixon should have locked the project'

    put :update, { format: 'json', id: @project_three, project: { lock: 'false' } },  user_id: @kate
    assert_response :success
    assert Project.find(@project_three).lock == false, 'Kate should have unlocked the project'

    put :update, { format: 'json', id: @project_three, project: { lock: 'true' } },  user_id: @crunch
    assert_response :unprocessable_entity
    assert Project.find(@project_three).lock == false, 'Crunch should not have locked the project'
  end
end
