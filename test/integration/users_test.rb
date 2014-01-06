require 'test_helper'

class UsersTest < ActionDispatch::IntegrationTest
  include CapyHelper

  setup do
    Capybara.current_driver = Capybara.javascript_driver
    Capybara.default_wait_time = 15
  end

  teardown do
    finish
  end
  
  test "contributions" do 
    login("nixon", "12345")
    
    visit "/projects/1"
    click_on "Like"
    
    visit "/users/nixon"
    assert page.has_content? "Media Test"
    
    click_on "My Projects"
    assert page.has_content? "Media Test"
    
    click_on "Data Sets"
    assert page.has_content? "Needs Media"
    
    find('.nav-tabs').click_on "Visualizations"
    assert page.has_content? "Needs Media"
     
  end
end