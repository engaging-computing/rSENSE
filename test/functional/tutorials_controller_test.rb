require 'test_helper'

class TutorialsControllerTest < ActionController::TestCase
  setup do
    @tutorial = tutorials(:one)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:tutorials)
    assert_valid_html response.body
  end

  test 'should get index sorted' do
    get :index, format: 'json', sort: 'created_at'
    assert_response :success
  end

  test 'should get index ordered' do
    get :index, format: 'json', order: 'ASC'
    assert_response :success
  end

  test 'should get index paged' do
    get :index, format: 'json', per_page: '1'
    assert JSON.parse(response.body).length == 1, 'Should have only had one tutorial returned'
  end

  test 'should get index searched' do
    get :index, format: 'json', search: 'Three'
    assert JSON.parse(response.body).length == 1, 'Should have only had one tutorial returned'
    assert JSON.parse(response.body).first['name'] == 'Tutorial Three', "Should have found \"Tutorial Three\""
    assert_response :success
  end

  test 'should create tutorial' do
    nixon = sign_in('user', users(:nixon))
    assert_difference('Tutorial.count') do
      post :create, { tutorial: { content: @tutorial.content, title: @tutorial.title } },  user_id: nixon
    end

    assert_redirected_to tutorial_path(assigns(:tutorial))
  end

  test 'should not create tutorial as non-admin' do
    kate = sign_in('user', users(:kate))
    assert_difference('Tutorial.count', 0) do
      post :create, { tutorial: { content: @tutorial.content, title: @tutorial.title } },  user_id: kate
    end

    assert_response 403
  end

  test 'should show tutorial' do
    get :show, id: @tutorial
    assert_response :success
    assert_valid_html response.body
  end

  test 'should get edit' do
    nixon = sign_in('user', users(:nixon))
    get :edit, { id: @tutorial },  user_id: nixon
    assert_response :success
    assert_valid_html response.body
  end

  test 'should update tutorial' do
    nixon = sign_in('user', users(:nixon))
    put :update, { id: @tutorial, tutorial: { content: @tutorial.content, title: @tutorial.title } },
       user_id: nixon
    assert_redirected_to tutorial_path(assigns(:tutorial))
  end

  test 'should feature tutorial' do
    nixon = sign_in('user', users(:nixon))
    put :update, { id: @tutorial, tutorial: { featured: 'true' } },  user_id: nixon
    assert_redirected_to tutorial_path(assigns(:tutorial))
    assert Tutorial.find(@tutorial.id).featured == true

    put :update, { id: @tutorial, tutorial: { featured: 'false' } },  user_id: nixon
    assert_redirected_to tutorial_path(assigns(:tutorial))
    assert Tutorial.find(@tutorial.id).featured == false
  end

  test 'should destroy tutorial' do
    nixon = sign_in('user', users(:nixon))
    assert_difference('Tutorial.count', -1) do
      delete :destroy, { id: @tutorial },  user_id: nixon
    end

    assert_redirected_to tutorials_path
  end

  test 'should not destroy tutorial as non-admin' do
    kate = sign_in('user', users(:kate))
    assert_difference('Tutorial.count', 0) do
      delete :destroy, { id: @tutorial },  user_id: kate
    end

    assert_response 403
  end
end
