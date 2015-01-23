require 'test_helper'
class BugReportTest < ActionDispatch::IntegrationTest
  include CapyHelper

  self.use_transactional_fixtures = false

  setup do
    Capybara.current_driver = :webkit
    Capybara.default_wait_time = 15
  end

  teardown do
    finish
  end

  test 'get bug report page' do
    visit '/'
    click_on 'Report a Bug'

    assert page.has_content?('Report a Bug: Do you have a GitHub account?'), 'Did not get to report a bug page.'
  end

  test 'get bug report page with github account' do
    login('nixon@whitehouse.gov', '12345')
    visit '/report_bug'
    find('#github_account').click

    assert page.has_content?('Sign in'), 'Should have redirected to github for authorization'
  end

  test 'get bug report page without account' do
    visit '/report_bug'
    find('#no_github_account').click

    assert page.has_content?('Report a Bug'), 'Should have redirected to github for authorization'
  end

  test 'get bug report page with github account not logged in' do
    visit '/report_bug'
    find('#github_account').click

    assert page.has_content?('Log in to iSENSE'), 'Should have redirected to github for authorization'
  end
end