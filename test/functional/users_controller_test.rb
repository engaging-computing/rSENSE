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
end
