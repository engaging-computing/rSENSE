require 'test_helper'

class TutorialsControllerTest < ActionController::TestCase
  setup do
    @tutorial = tutorials(:one)
  end

  test 'should get index' do
    get :index
    assert_response :success
    # HTML5 Validation is being skipped until the validator is fixed
    # assert_valid_html response.body
  end

  test 'should create tutorial' do
    nixon = sign_in('user', users(:nixon))
    assert_difference('Tutorial.count') do
      post :create, { tutorial: { title: @tutorial.title, category: @tutorial.category,  youtube_url: @tutorial.youtube_url } },  user_id: nixon
    end

    assert_redirected_to '/tutorials'
  end

  test 'should not create tutorial as non-admin' do
    kate = sign_in('user', users(:kate))
    assert_difference('Tutorial.count', 0) do
      post :create, { tutorial: { title: @tutorial.title, category: @tutorial.category,  youtube_url: @tutorial.youtube_url } },  user_id: kate
    end

    assert_response 403
  end

  test 'should show tutorial' do
    sign_in('user', users(:nixon))
    get :show, id: @tutorial
    assert_redirected_to tutorials_path
    # HTML5 Validation is being skipped until the validator is fixed
    # assert_valid_html response.body
  end

  test 'should get edit' do
    nixon = sign_in('user', users(:nixon))
    get :edit, { id: @tutorial },  user_id: nixon
    assert_response :success
    # HTML5 Validation is being skipped until the validator is fixed
    # assert_valid_html response.body
  end

  test 'should update tutorial' do
    nixon = sign_in('user', users(:nixon))
    put :update, { id: @tutorial, tutorial: { title: @tutorial.title, category: @tutorial.category, youtube_url: @tutorial.youtube_url } },
       user_id: nixon
    assert_redirected_to tutorial_path(assigns(:tutorial))
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
