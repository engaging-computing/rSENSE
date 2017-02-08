require 'test_helper'

class VisualizationsControllerTest < ActionController::TestCase
  setup do
    @vis1 = visualizations(:visualization1)

    @vis2 = visualizations(:tasty_vis)
    @vis2.save

    @tgd = data_sets(:thanksgiving)

    @svg = Rails.root.join('test', 'CSVs', 'Konqi.svg')
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:visualizations)
    # HTML5 Validation is being skipped until the validator is fixed
    # assert_valid_html response.body
  end

  test 'should create visualization' do
    kate = sign_in('user', users(:kate))

    assert_difference('Visualization.count') do
      post :create, { visualization: { content: @vis1.content, data: @vis1.data, project_id: @vis1.project_id,
        globals: @vis1.globals, title: @vis1.title, user_id: @vis1.user_id } },  user_id: kate
    end
    assert_redirected_to visualization_path(assigns(:visualization))
    assert_difference('Visualization.count') do
      post :create, { visualization: { content: @vis1.content, data: @vis1.data, project_id: @vis1.project_id,
        globals: @vis1.globals, title: @vis1.title, user_id: @vis1.user_id, tn_file_key: 'abcd', tn_src: 'image' } },  user_id: kate
    end
    # Skipping this part for now because it's failing on Circle. Debug later.
    # assert_difference('Visualization.count') do
    #   post :create, { visualization: { content: @vis1.content, data: @vis1.data, project_id: @vis1.project_id,
    #     globals: @vis1.globals, title: @vis1.title, user_id: @vis1.user_id, svg: @svg } },  user_id: kate
    # end
    @svg = File.read(@svg)
    assert_difference('Visualization.count') do
      post :create, { visualization: { content: @vis1.content, data: @vis1.data, project_id: @vis1.project_id,
        globals: @vis1.globals, title: @vis1.title, user_id: @vis1.user_id, svg: @svg } },  user_id: kate
    end
    post :create, { format: 'json', visualization: { content: @vis1.content, data: @vis1.data, project_id: @vis1.project_id,
        globals: @vis1.globals, user_id: @vis1.user_id, svg: @svg } },  user_id: kate
    assert_response :unprocessable_entity
  end

  test 'should show visualization' do
    kate = sign_in('user', users(:kate))
    get :show, { id: @vis2.id },  user_id: kate
    assert_response :success
    # HTML5 Validation is being skipped until the validator is fixed
    # assert_valid_html response.body

    get :show, { id: @vis2.id, presentation: true },  user_id: kate
    assert_response :success
  end

  test 'should show thanksgiving dinner data' do
    get :displayVis,  id: @tgd.project_id, datasets: [@tgd.id]
    assert_response :success
    # HTML5 Validation is being skipped until the validator is fixed
    # assert_valid_html response.body
  end

  test 'should get edit' do
    nixon = sign_in('user', users(:nixon))
    get :edit, { id: @vis2 },  user_id: nixon
    assert_response :success
    # HTML5 Validation is being skipped until the validator is fixed
    # assert_valid_html response.body
  end

  test 'should update visualization' do
    kate = sign_in('user', users(:kate))
    put :update, { id: @vis1, visualization: { content: @vis1.content, data: @vis1.data,
      project_id: @vis1.project_id, globals: @vis1.globals, title: @vis1.title, user_id: users(:kate).id } },
       user_id: kate
    assert_redirected_to visualization_path(assigns(:visualization))
    sign_out('user')

    nixon = sign_in('user', users(:nixon))
    put :update, { id: @vis1, visualization: { featured: '1', content: @vis1.content, data: @vis1.data,
      project_id: @vis1.project_id, globals: @vis1.globals, title: @vis1.title, user_id: users(:kate).id } },
       user_id: nixon
    assert_redirected_to visualization_path(assigns(:visualization))
    put :update, { id: @vis1, visualization: { featured: '0', content: @vis1.content, data: @vis1.data,
      project_id: @vis1.project_id, globals: @vis1.globals, title: @vis1.title, user_id: users(:kate).id } },
       user_id: nixon
    assert_redirected_to visualization_path(assigns(:visualization))
  end

  test 'should destroy visualization' do
    kate = sign_in('user', users(:kate))
    assert_difference('Visualization.count', -1) do
      delete :destroy, { id: @vis2 },  user_id: kate
    end

    assert_redirected_to visualizations_path
  end

  test 'should for realz show vis' do
    get :displayVis,  id: @vis2.project.id
    assert_response :success
    # HTML5 Validation is being skipped until the validator is fixed
    # assert_valid_html response.body
  end

  test 'should redirect to 404' do
    # Project doesn't exist:
    get :displayVis, id: 0
    assert_redirected_to '/404.html'
    # Data set doesn't belong to project:
    get :displayVis, id: @vis1.project.id, datasets: [@tgd.id]
    assert_redirected_to '/404.html'
  end
end
