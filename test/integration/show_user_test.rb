require 'test_helper'

class ShowUserTest < ActionDispatch::IntegrationTest
  include CapyHelper

  self.use_transactional_fixtures = false

  setup do
    Capybara.current_driver = :webkit
    Capybara.default_wait_time = 15
    Capybara.ignore_hidden_elements = true
  end

  teardown do
    finish
  end

  test 'contributions' do
    login('nixon@whitehouse.gov', '12345')

    pid = projects(:media_test).id
    visit "/projects/#{pid}"
    click_on 'Like'

    assert find('.like_display').has_content?('1'), 'Like updated'

    @nixon = users(:nixon)

    visit "/users/#{@nixon.id}"
    click_on 'Liked Projects'
    assert page.has_content?('Media Test'), 'View admin user'

    click_on 'My Projects'
    assert page.has_content?('Media Test'), 'View projects list'

    # Count deletes and delete the first project
    count = page.all(:css, '.contrib-delete-link').length
    assert page.has_css?('.contrib-delete-link'), 'Delete project should exist'
    page.driver.browser.accept_js_confirms
    page.first(:css, '.contrib-delete-link').click

    # Verify that there is one less project
    assert page.has_css?('.contrib-delete-link', :count => (count - 1)),
    'Deleted project should be hidden'

    click_on 'Data Sets'
    assert page.has_content?('Needs Media'), 'View data sets list'

    find('.nav-tabs').click_on 'Visualizations'
    assert page.has_content?('Needs Media'), 'View viz list'

    find('.info_edit_link').click
    assert page.has_css?('.info_edit_box'), 'showed text box'

    fill_in 'info_edit_value', with: 'George Bush'
    find('.info-save-button').click
    assert find('.info-show-value').has_content?('George Bush'), 'name updated'
  end
end
