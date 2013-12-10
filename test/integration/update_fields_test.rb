require 'test_helper'

class MakeProjectTest < ActionDispatch::IntegrationTest
  include CapyHelper

  setup do
    Capybara.current_driver = Capybara.javascript_driver
    Capybara.default_wait_time = 15
  end

  teardown do
    finish
  end
  
  test "edit fields" do
    login("kate", "12345")
    click_on "Projects"
    find('#addProjectButton').click
    wait_for_id('new_name')
    find('#new_name').set("Fields Test")
    click_on "Finish"
    
    assert page.has_content?("Fields"), "Project page should have 'Fields'"
    
    find('#manual_fields').click
    
    find('#new_field').find(:xpath, 'option[2]').select_option
    assert page.has_content?("Field added")
    find('.field_delete').click
    
    find('#new_field').find(:xpath, 'option[3]').select_option
    assert page.has_content?("Field added")
    find('.field_delete').click
    
    find('#new_field').find(:xpath, 'option[4]').select_option
    assert page.has_content?("Field added")
    find('.field_delete').click
    
    find('#new_field').find(:xpath, 'option[5]').select_option
    assert page.has_content?("Field added")
    
  end
end