require 'test_helper'

class ShowUserTest < ActionDispatch::IntegrationTest
  include CapyHelper

  self.use_transactional_fixtures = false

  setup do
    Capybara.current_driver = :webkit
    Capybara.default_wait_time = 15
  end

  teardown do
    finish
  end

  test 'contributions' do
    login('nixon@whitehouse.gov', '12345')

    visit '/projects/1'
    click_on 'Like'

    assert find('.like_display').has_content?('1'), 'Like updated'

    @nixon = users(:nixon)

    visit "/users/#{@nixon.id}"
    assert page.has_content?('Media Test'), 'View admin user'

    click_on 'My Projects'
    assert page.has_content?('showing tab: My Projects'), 'Switched tab'
    assert page.has_content?('Media Test'), 'View projects list'

    click_on 'Data Sets'
    assert page.has_content?('showing tab: Data Sets'), 'Switched tab'
    assert page.has_content?('Needs Media'), 'View data sets list'

    find('.nav-tabs').click_on 'Visualizations'
    assert page.has_content?('showing tab: Visualizations'), 'Switched tab'
    assert page.has_content?('Needs Media'), 'View viz list'

    find('.info_edit_link').click

    assert page.has_css?('.info_edit_box'), 'showed text box'

    fill_in 'info_edit_value', with: 'George Bush'

    find('.info-save-button').click

    assert page.has_content?('saving...'), 'click event'

    assert page.has_content?('value saved'), 'saved name'
    assert find('.info-show-value').has_content?('George Bush'), 'name updated'
  end
end
