require 'test_helper'

class BasicsTest < ActionDispatch::IntegrationTest
  test "logging in" do
    visit '/'
    click_on 'Login'
    fill_in 'Username', with: 'kate'
    fill_in 'Password', with: '12345'
    find('#login_box').click_on('Login')

    assert page.has_content?('Featured Projects')
    assert find('#title_bar').has_content?('Kate C.')
  end
end
