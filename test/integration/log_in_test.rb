require 'test_helper'
require_relative 'base_integration_test'

class CloneProjectTest < IntegrationTest
  test 'should log in and get notification' do
    visit '/'
    click_on('Login')
    fill_in 'user_email', with: 'nixon@whitehouse.gov'
    fill_in 'user_password', with: '12345'
    find(:css, '.mainContent').click_on('Log in')

    assert page.has_content?('Signed in successfully.'), 'Did not successfully log in'

    logout
  end

  test 'should not log in because of bad password' do
    visit '/'
    click_on('Login')
    fill_in 'user_email', with: 'nixon@whitehouse.gov'
    fill_in 'user_password', with: '12345678910'
    find(:css, '.mainContent').click_on('Log in')

    assert page.has_content?('Invalid Email or password.'), 'Did not fail to log in'
  end
end
