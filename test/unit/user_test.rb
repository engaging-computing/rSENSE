require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # Creates a new user and tests that the default fields are correctly set

  # Declares a new user
  def setup
    @user = User.new
  end

  # Passes if email is nil
  test 'email is nil' do
    assert_default_nil(@user, @user.email)
  end

  # Passes if admin is false
  test 'admin is false' do
    assert_default_false(@user, @user.admin)
  end

  # Passes if hidden is false
  test 'hidden is false' do
    assert_default_false(@user, @user.hidden)
  end

  # Passes if password_confirmation and password match
  test 'password_confirmation matches password' do
    if @user.password
      assert_equal @user.password, @user.password_confirmation, 'Password_confirmation does not match password.'
    else
      assert_nil @user.password_confirmation, 'Password_confirmation does not match password.'
    end
  end

  # ---------------------------------------------------
  # Testing with fixtures

  test 'email' do
    assert_equal 'kcarcia@cs.uml.edu', users(:kate).email
  end

  test 'admin' do
    assert_equal false, users(:kate).admin
  end

  test 'to_hash' do
    h = users(:nixon).to_hash
    keys = ['dataSets', 'mediaObjects', 'projects', 'tutorials', 'visualizations']

    keys.each do |x|
      assert !h[x.to_sym].nil?
      assert !h[x.to_sym].empty?
    end
  end
end
