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

    assert page.has_content?('Delete'), 'Delete project should exist'
    page.all('tr').each do |tr|
      if tr.text =~ /Delete This Project/
        tr.click_on('Delete')
        page.driver.browser.accept_js_confirms
      end
    end

    assert page.has_no_content?('Delete'), 'Project removed from list'

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
