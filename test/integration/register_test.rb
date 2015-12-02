require 'test_helper'
require_relative 'base_integration_test'

class RegisterTest < IntegrationTest
  test 'create a user' do
    visit '/'
    find('.navbar').click_on('Register')
    assert page.has_content?('Register for iSENSE')
    fill_in 'user_name',       with: 'Mark S.'
    fill_in 'user_email',      with: 'msherman@cs.uml.edu'
    fill_in 'user_password',   with: 'pietime'
    fill_in 'user_password_confirmation',
                               with: 'pietime'
    save_and_open_page
    click_on 'Create User'

    assert find('.navbar').has_content?('News'), 'No error registering'
    assert page.has_content?('Mark S.')

    logout

    login('msherman@cs.uml.edu', 'pietime')

    assert find('.navbar').has_content?('News'), 'Can log in with new user'
  end
end
