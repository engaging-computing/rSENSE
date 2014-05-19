require 'test_helper'

class UsersTest < ActionDispatch::IntegrationTest
  include CapyHelper

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
    assert page.has_content?('Media Test'), 'View projects list'

    puts `tail -80 #{Rails.root}/log/test.log`

    click_on 'Data Sets'
    assert page.has_content?('Needs Media'), 'View data sets list'

    find('.nav-tabs').click_on 'Visualizations'
    assert page.has_content?('Needs Media'), 'View viz list'
  end
end
