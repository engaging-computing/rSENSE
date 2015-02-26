require 'test_helper'

class RegisterTest < ActionDispatch::IntegrationTest
  include CapyHelper

  setup do
    Capybara.current_driver = :webkit
    Capybara.default_wait_time = 15
  end

  teardown do
    finish
  end

  #   test 'create a user' do
  #     visit '/'
  #     find('.navbar').click_on('Register')
  #     assert page.has_content?('Register for iSENSE')
  #     fill_in 'user_name',       with: 'Mark S.'
  #     fill_in 'user_email',      with: 'msherman@cs.uml.edu'
  #     fill_in 'user_password',   with: 'pietime'
  #     fill_in 'user_password_confirmation',
  #                                with: 'pietime'
  #     click_on 'Create User'
  #
  #     assert find('.navbar').has_content?('News'), 'No error registering'
  #     assert page.has_content?('Mark S.')
  #
  #     logout
  #
  #     login('msherman@cs.uml.edu', 'pietime')
  #
  #     assert find('.navbar').has_content?('News'), 'Can log in with new user'
  #   end
end
