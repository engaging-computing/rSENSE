require 'test_helper'
require_relative 'base_integration_test'

class SmallPageTest < IntegrationTest
  self.use_transactional_fixtures = false

  test 'only first paragraph' do
    login('nixon@whitehouse.gov', '12345')
    page.driver.browser.window_resize(page.driver.browser.get_window_handle,
                                      900, 500)
    visit '/'
    assert page.has_no_content?('Second Paragraph'), 'Second paragraph should not be shown.'

    proj_id = projects(:media_test).id
    visit "/projects/#{proj_id}"

    find('#content-edit-btn').click
    fill_in_content('')
    find('#content-save-btn').click

    assert page.has_content?('Project was successfully updated.'), 'Flash text'

    visit '/'

    assert page.has_no_content?('First Paragraph'), 'First paragraph should have been deleted.'
    page.driver.browser.window_resize(page.driver.browser.get_window_handle,
                                      1100, 800)
  end
end
