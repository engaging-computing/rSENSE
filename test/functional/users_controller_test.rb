require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
  end

  test 'should not get index as user' do
    kate = sign_in('user', users(:kate))
    get :index, {},  user_id: kate
    assert_response :forbidden
  end

  test 'should get index as admin' do
    nixon = sign_in('user', users(:nixon))
    get :index, {},  user_id: nixon
    assert_response :success
    assert_not_nil assigns(:users)
    assert_valid_html response.body
  end

  test 'should get index paged' do
    nixon = sign_in('user', users(:nixon))
    get :index, { format: 'json', per_page: 1 },  user_id: nixon
    assert_response :success
    assert JSON.parse(response.body).count == 1, 'Should only have got one user back'
  end

  test 'should get index sorted' do
    nixon = sign_in('user', users(:nixon))
    get :index, { format: 'json', sort: 'ASC' },  user_id: nixon
    assert_response :success
    body = JSON.parse(response.body)
    assert Date.parse(body[0]['createdAt']) < Date.parse(body[1]['createdAt']), 'Was not in ascending order'
  end

  test 'should get index searched' do
    nixon = sign_in('user', users(:nixon))
    get :index, { format: 'json', search: 'kate', sort: 'ASC' },  user_id: nixon
    assert_response :success
  end

  test 'should get new' do
    skip('No longer valid as of devise integration')
  end

  test 'should create user' do
    skip('No longer valid as of devise integration')
  end

  test 'should show errors on bad attempt to create user' do
    skip('No longer valid as of devise integration')
  end

  test 'should show user' do
    kate = sign_in('user', users(:kate))
    get :show, { id: users(:kate).id },  user_id: kate
    assert_response :success
    assert_valid_html response.body
  end

  test 'should show user with contributions' do
    kate = sign_in('user', users(:kate))
    get :show, { format: 'json',  id: users(:kate).id, recur: 'true' },  user_id: kate
    body = JSON.parse(response.body)
    assert body.key?('visualizations'), 'Recur should show visualizations'
    assert body.key?('dataSets'), 'Recur should show data sets'
    assert body.key?('mediaObjects'), 'Recur should show mediaObjects'
    assert body.key?('projects'), 'Recur should show projects'
    assert_response :success
  end

  test 'should not show user (html)' do
    nixon = sign_in('user', users(:nixon))
    get :show, { id: 'GreenGoblin' }, user_id: nixon
    assert_response :not_found
  end

  test 'should not show user (json)' do
    nixon = sign_in('user', users(:nixon))
    get :show, { format: 'json', id: 'GreenGoblin' }, user_id: nixon
    assert_response :unprocessable_entity
  end

  test 'should get edit' do
    skip('No longer valid as of devise integration')
  end

  test 'should update user' do
    skip('No longer valid as of devise integration')
  end

  test 'should update bio' do
    kate = sign_in('user', users(:kate))
    put :update, {  id: users(:kate).id, user: { bio: 'Snackcakes are Delicious' } },  user_id: kate
    assert_redirected_to user_path(assigns(:user))
  end

  test 'should not update email without password' do
    kate = sign_in('user', users(:kate))
    put :update, {  id: users(:kate).id, user: { email: 'fake@derp.com', email_confirmation: 'fake@derp.com' } },
       user_id: kate
    assert_redirected_to user_path(assigns(:user)) + '/edit'
    assert_not_nil flash[:error]
  end

  test 'user cannot delete themselves' do
    kate = sign_in('user', users(:kate))
    assert_difference('User.count', 0) do
      delete :destroy, { id: users(:kate).id },  user_id: kate
    end

    assert_not_nil(flash[:debug])
    assert_response :redirect
  end

  test 'should destroy user' do
    nixon = sign_in('user', users(:nixon))
    assert_difference('User.count', -1) do
      delete :destroy, { id: users(:kate).id },  user_id: nixon
    end

    assert_redirected_to users_path
  end

  test 'should get contributions' do
    kate = sign_in('user', users(:kate))
    get :contributions, { id: users(:kate).id },  user_id: kate
    assert_response :success
  end

  test 'should get contributions with filters' do
    kate = sign_in('user', users(:kate))
    get :contributions, {  id: users(:kate).id, filters: 'Liked Projects' },  user_id: kate
    assert_response :success
    get :contributions, {  id: users(:kate).id, filters: 'My Projects' },  user_id: kate
    assert_response :success
    get :contributions, {  id: users(:kate).id, filters: 'Data Sets' },  user_id: kate
    assert_response :success
    get :contributions, {  id: users(:kate).id, filters: 'Visualizations' },  user_id: kate
    assert_response :success
  end

  test 'should validate user' do
    skip('No longer valid as of devise integration')
  end

  test 'bad validation should 404' do
    skip('No longer valid as of devise integration')
  end

  test 'should show password reset request form' do
    skip('No longer valid as of devise integration')
  end

  test 'should send password reset email for email' do
    skip('No longer valid as of devise integration')
  end

  test 'password reset URL should redirect to pw change form' do
    skip('No longer valid as of devise integration')
  end

  test 'bad password reset URL should 404' do
    skip('No longer valid as of devise integration')
  end

  test 'password change form should work after reset link' do
    skip('No longer valid as of devise integration')
  end

  test 'password change form should work normally' do
    skip('No longer valid as of devise integration')
  end

  test 'password change form should work for admin' do
    skip('No longer valid as of devise integration')
  end

  test 'password change form should fail for other user' do
    skip('No longer valid as of devise integration')
  end

  test 'actually change password' do
    skip('No longer valid as of devise integration')
  end

  test 'actually change email' do
    skip('No longer valid as of devise integration')
  end
end
