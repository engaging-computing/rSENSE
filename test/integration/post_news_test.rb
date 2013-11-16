require 'test_helper'

class MakeNewsTest < ActionDispatch::IntegrationTest
  include CapyHelper

  setup do
    Capybara.current_driver = Capybara.javascript_driver
    Capybara.default_wait_time = 15
  end

  teardown do
    finish
  end
  
  test "add a news item" do
    login("nixon", "12345")
    assert find('.navbar').has_content?('Richard N.')

    click_on "News"
    assert page.has_no_content?("The Quick Brown Fox")
    
    click_on "Add News Item"
    assert page.has_content?("News entry was successfully created.")

    find('.menu_edit_link').click
    click_on("Edit Title")
    find('#appendInput').set("The Quick Brown Fox")
    all('.menu_save_link').first.click

    sleep 1

    find('#hide_news_checkbox').click

    sleep 1

    visit '/news'

    assert page.has_content?("The Quick Brown Fox"), "News Was Added"

    logout

    login("kate", "12345")
    click_on "News" 
    
    assert page.has_no_content?("Add News Item")
    assert page.has_content?("The Quick Brown Fox")
  end
end
