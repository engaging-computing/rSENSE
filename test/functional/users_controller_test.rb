require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @user  = users(:kate)
    @admin = users(:nixon)
  end

  test "should get index" do
    get :index, {}, { user_id: @user }
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user" do
    assert_difference('User.count') do
      post :create, user: { content: "", email: "john@example.com", firstname: "John", lastname: "Fertitta", 
        username: "jfertitt", password: "iguana", password_confirmation: "iguana" }
      puts flash[:debug] unless flash[:debug].nil?
    end

    assert_redirected_to user_path(assigns(:user))

    john = User.find_by_email("john@example.com")

    assert_not_nil john
    assert_equal john.validated?, false, 
      "New user should not be validated"
  end

  test "should show user" do
    get :show, { id: @user }, { user_id: @user }
    assert_response :success
  end

  test "should get edit" do
    get :edit, { id: @user }, { user_id: @user }
    assert_response :success
  end

  test "should update user" do
    put :update, {id: @user, user: { content: @user.content, email: @user.email, firstname: @user.firstname, 
      lastname: @user.lastname, username: @user.username, validated: @user.validated }}, { user_id: @user }
    assert_redirected_to user_path(assigns(:user))
  end

  test "user can't delete themselves" do
    assert_difference('User.count', 0) do
      delete :destroy, { id: @user }, { user_id: @user }
    end
      
    assert_not_nil(flash[:debug])
    assert_response :redirect
  end

  test "should delete user" do
    assert_difference('User.count', 0) do
      delete :destroy, { id: @user }, { user_id: @admin }
    end

    @u0 = User.find_by_id(@user)
    assert_match(/\@deleted\.org$/, @u0.email)

    assert_redirected_to users_path
  end

  test "should get contributions" do
    get :contributions, { id: @user }, { user_id: @user }
    assert_response :success
  end

  test "should validate user" do
    captn = users(:crunch)
    assert_equal captn.validated?, false, "Not validated"

    get :validate, { key: "abcd" }
    assert_response :success

    captn = User.find_by_username("crunch")
    assert_equal captn.validated?, true, "Validated"
  end

  test "bad validation should 404" do
    get :validate, { key: "invalid" }
    assert_response :not_found
  end

  test "should show password reset request form" do
    get :pw_request
    assert_response :success
  end

  test "should send password reset email for username" do
    post :pw_send_key, { username_or_email: 'kate' }
    assert_response :success
    
    email = ActionMailer::Base.deliveries.last
    user  = User.find_by_username('kate')
    assert_contains user.validation_key, email.body
    assert_not_equal user.validation_key, @user.validation_key
  end

  test "should send password reset email for email" do
    post :pw_send_key, { username_or_email: 'kcarcia@cs.uml.edu' }
    assert_response :success

    email = ActionMailer::Base.deliveries.last
    user  = User.find_by_email('kcarcia@cs.uml.edu')
    assert_contains user.validation_key, email.body
    assert_not_equal user.validation_key, @user.validation_key
  end

  test "password reset URL should redirect to pw change form" do
    crunch = users(:crunch)

    get :pw_reset, { key: 'abcd' }
    assert_redirected_to edit_user_path(crunch)
    assert_not_nil session[:pw_change]
    assert_equal session[:user_id], crunch.id
  end

  test "bad password reset URL should 404" do
    get :pw_reset, { key: 'invalid' }
    assert_response :not_found
    assert_nil session[:pw_change]
    assert_nil session[:user_id]
  end

  test "password change form should work after reset link" do
    get :edit, { id: @user }, { pw_change: true, user_id: @user }
    assert_response :success
    assert_contains "New Password", response.body
    assert_not_contains "Current Password", response.body
  end

  test "password change form should work normally" do
    get :edit, { id: @user }, { user_id: @user }  
    assert_response :success
    assert_contains "New Password", response.body
    assert_contains "Current Password", response.body
  end

  test "password change form should work for admin" do
    get :edit, { id: @user }, { user_id: @admin }
    assert_response :success
    assert_contains "New Password", response.body
    assert_not_contains "Current Password", response.body
  end

  test "password change form should fail for other user" do
    get :edit, { id: @user }, { user_id: users(:crunch) }
    assert_response :not_found
  end
end
