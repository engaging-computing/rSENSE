require 'test_helper'

class BasicsTest < ActionDispatch::IntegrationTest
  include CapyHelper

  setup do
    Capybara.current_driver = Capybara.javascript_driver
    Capybara.default_wait_time = 15
  end

  teardown do
    finish
  end

  test "create a user" do
    visit '/'
    find("#title_bar .visible-desktop div").click_on("Register")
    fill_in "First Name", with: "Mark"
    fill_in "Last Name",  with: "Sherman"
    fill_in "Username",   with: "mark"
    fill_in "Email",      with: "msherman@cs.uml.edu"
    fill_in "Password:",   with: "pietime"
    fill_in "Password Confirmation",
                          with: "pietime"
    click_on "Create User"

    assert find('#title_bar').has_content?("News")
  end

  test "user logs in" do
    login('kate', '12345')

    assert page.has_content?('Featured Projects')
    assert find('#title_bar').has_content?('Kate C.')
    
    logout
    
    assert find('#title_bar').has_no_content?('Kate C.')
  end

  test "admin logs in" do
    login('nixon', '12345')

    assert page.has_content?('Featured Projects')
    assert find('#title_bar').has_content?('Richard N.')

    logout
    
    assert find('#title_bar').has_no_content?('Richard N.')
  end
end
