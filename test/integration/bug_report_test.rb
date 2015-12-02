require 'test_helper'
require_relative 'base_integration_test'

class BugReportTest < IntegrationTest
  self.use_transactional_fixtures = false

  test 'get bug report page' do
    visit '/'
    click_on 'Report a Bug'

    assert page.has_content?('Report a Bug: Do you have a GitHub account?'), 'Did not get to report a bug page.'
  end

  test 'get bug report page without account' do
    visit '/report_bug'
    find(:css, '#no_github_account').click

    assert page.has_content?('Report a Bug'), 'Should have redirected to github for authorization'
  end

  test 'get bug report page with github account not logged in' do
    visit '/report_bug'
    find(:css, '#github_account').click
    save_and_open_page
    assert page.has_content?('Log in to iSENSE'), 'Should have redirected to github for authorization'
  end
end
