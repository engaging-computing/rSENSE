# Put tests based on how the user interacts with the site here
require 'test_helper'
require_relative 'base_integration_test'

class UserInteractionsTest < IntegrationTest
  self.use_transactional_fixtures = false

  setup do
    @slick_project = projects(:slickgrid_project)
  end

  test 'edit button should not show on projects you don\'t own' do
    visit project_path(@slick_project)
    assert page.has_no_content?('Edit'), 'Edit button appears on project without being logged in'
    login('pson@cs.uml.edu', '12345')
    visit project_path(@slick_project)
    assert page.has_no_content?('Edit'), 'Edit button appears on project that the user does not own.'
  end
end