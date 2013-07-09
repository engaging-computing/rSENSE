require 'test_helper'

class UserTest < ActiveSupport::TestCase

  # Creates a new user and tests that the default fields are correctly set
  
  # Declares a new user
  def setup
    @user = User.new
  end
  
  # Passes if email is nil
  test "email is nil" do
    assert_default_nil( @user, @user.email )
  end
  
  # Passes if validated is false
  test "validated is false" do
    assert_default_false( @user, @user.validated )
  end
  
  # Passes if admin is false
  test "admin is false" do
    assert_default_false( @user, @user.admin )
  end
  
  # Passes if content is nil
  test "content is nil" do
    assert_default_nil( @user, @user.content )
  end

  # Passes if hidden is false
  test "hidden is false" do
    assert_default_false( @user, @user.hidden )
  end
  
  # Passes if password_confirmation and password match
  test "password_confirmation matches password" do
  	assert_equal @user.password, @user.password_confirmation,  "Password_confirmation does not match password."
  end
  
  # ---------------------------------------------------
  # Testing with fixtures
  
  test "first name" do
     assert_equal "kate", users(:one).firstname
  end  

  test "last name" do
     assert_equal "carcia", users(:one).lastname
  end
  
  test "username" do
     assert_equal "kate", users(:one).username
  end
 
  test "email" do
     assert_nil( users(:one).email, "Expected email is nil." )
  end
  
  test "validation" do
    assert_equal false, users(:one).validated
  end
  
  test "admin" do
    assert_equal false, users(:one).admin
  end
  
  test "content" do
     assert_nil( users(:one).content, "Expected content is nil." )
  end

end