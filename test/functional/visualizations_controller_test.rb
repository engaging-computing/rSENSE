require 'test_helper'

class VisualizationsControllerTest < ActionController::TestCase
  setup do
    @kate = users(:kate)
    @admin = users(:nixon)

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
    assert_valid_html response.body
  end

  test 'should create visualization' do
    assert_difference('Visualization.count') do
      post :create, { visualization: { content: @vis1.content, data: @vis1.data, project_id: @vis1.project_id,
        globals: @vis1.globals, title: @vis1.title, user_id: @vis1.user_id } },  user_id: @kate.id
    end
    assert_redirected_to visualization_path(assigns(:visualization))
    assert_difference('Visualization.count') do
      post :create, { visualization: { content: @vis1.content, data: @vis1.data, project_id: @vis1.project_id,
        globals: @vis1.globals, title: @vis1.title, user_id: @vis1.user_id, tn_file_key: 'abcd', tn_src: 'image' } },  user_id: @kate.id
    end
    assert_difference('Visualization.count') do
      post :create, { visualization: { content: @vis1.content, data: @vis1.data, project_id: @vis1.project_id,
        globals: @vis1.globals, title: @vis1.title, user_id: @vis1.user_id, svg: @svg } },  user_id: @kate.id
    end
    @svg = File.read(@svg)
    assert_difference('Visualization.count') do
      post :create, { visualization: { content: @vis1.content, data: @vis1.data, project_id: @vis1.project_id,
        globals: @vis1.globals, title: @vis1.title, user_id: @vis1.user_id, svg: @svg } },  user_id: @kate.id
    end
    post :create, { format: 'json', visualization: { content: @vis1.content, data: @vis1.data, project_id: @vis1.project_id,
        globals: @vis1.globals, user_id: @vis1.user_id, svg: @svg } },  user_id: @kate.id
    assert_response :unprocessable_entity
  end

  test 'should show visualization' do
    get :show, { id: @vis2.id },  user_id: @kate.id
    assert_response :success
    assert_valid_html response.body

    get :show, { id: @vis2.id, presentation: true },  user_id: @kate.id
    assert_response :success
  end

  test 'should show thanksgiving dinner data' do
    get :displayVis,  id: @tgd.project_id, datasets: [@tgd.id]
    assert_response :success
    assert_valid_html response.body
  end

  test 'should get edit' do
    get :edit, { id: @vis2 },  user_id: @admin
    assert_response :success
    assert_valid_html response.body
  end

  test 'should update visualization' do
    put :update, { id: @vis1, visualization: { content: @vis1.content, data: @vis1.data,
      project_id: @vis1.project_id, globals: @vis1.globals, title: @vis1.title, user_id: @kate.id } },
       user_id: @kate.id
    assert_redirected_to visualization_path(assigns(:visualization))
    put :update, { id: @vis1, visualization: { featured: '1', content: @vis1.content, data: @vis1.data,
      project_id: @vis1.project_id, globals: @vis1.globals, title: @vis1.title, user_id: @kate.id } },
       user_id: @admin.id
    assert_redirected_to visualization_path(assigns(:visualization))
    put :update, { id: @vis1, visualization: { featured: '0', content: @vis1.content, data: @vis1.data,
      project_id: @vis1.project_id, globals: @vis1.globals, title: @vis1.title, user_id: @kate.id } },
       user_id: @admin.id
    assert_redirected_to visualization_path(assigns(:visualization))
  end

  test 'should destroy visualization' do
    assert_difference('Visualization.count', -1) do
      delete :destroy, { id: @vis2 },  user_id: @kate.id
    end

    assert_redirected_to visualizations_path
  end

  test 'should for realz show vis' do
    get :displayVis,  id: @vis2.project.id
    assert_response :success
    assert_valid_html response.body
  end
end
