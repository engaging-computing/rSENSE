require 'test_helper'

class UserTest < ActiveSupport::TestCase

  # Creates a new user and tests that the default fields are correctly set
  
  # Defines and initializes a new user
  user = User.new
  
  # Passes if email is nil
  test "email is nil" do
    assert_nil( user.email, "Expected email is nil." )
  end
  
  # Passes if validated is false
  test "validated is false" do
    assert_equal( false, user.validated, "Expected validated is false." )
  end
  
  # Passes if admin is false
  test "admin is false" do
    assert_equal( false, user.admin, "Expected admin is false." )
  end
  
  # Passes if content is nil
  test "content is nil" do
    assert_nil( user.content, "Excepted content is nil." )
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
  
  test "validated" do
    assert_equal false, users(:one).validated
  end
  
  test "admin" do
    assert_equal false, users(:one).admin
  end
  
  test "content" do
     assert_nil( users(:one).content, "Expected content is nil." )
  end

end
