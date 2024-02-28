require 'test_helper'
require_relative 'base_integration_test'

class RegisterTest < IntegrationTest
  test 'create a user' do
    visit '/'
    find('.navbar').click_on('Register')
    assert page.has_content?('Register for iSENSE')
    fill_in 'user_name',       with: 'Mark S.'
    fill_in 'user_email',      with: 'msherman@cs.uml.edu'
    fill_in 'user_password',   with: 'pietimes'
    fill_in 'user_password_confirmation',
                               with: 'pietimes'
    click_on 'Create User'

    assert find('.navbar').has_content?('News'), 'No error registering'
    assert page.has_content?('Mark S.')

    logout
    login('msherman@cs.uml.edu', 'pietimes')

    assert find('.navbar').has_content?('News'), 'Can log in with new user'

    logout
  end

  test 'fail to create user for taken email' do
    visit '/'
    find('.navbar').click_on('Register')
    assert page.has_content?('Register for iSENSE')
    fill_in 'user_name',       with: 'Richard Nixon'
    fill_in 'user_email',      with: 'nixon@whitehouse.gov'
    fill_in 'user_password',   with: 'notacrook'
    fill_in 'user_password_confirmation',
                               with: 'notacrook'
    click_on 'Create User'

    assert page.has_content?('Email has already been taken'), 'Created duplicate user'
  end

  test 'fail to create user for password length' do
    visit '/'
    find('.navbar').click_on('Register')
    assert page.has_content?('Register for iSENSE')
    fill_in 'user_name',       with: 'Richard Nixon'
    fill_in 'user_email',      with: 'nixon@whitehouse.gov'
    fill_in 'user_password',   with: 'short'
    fill_in 'user_password_confirmation',
                               with: 'short'
    click_on 'Create User'

    assert page.has_content?('Password is too short (minimum is 8 characters)'), 'Created account with too short of a password'
  end
end
