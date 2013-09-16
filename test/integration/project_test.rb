require 'test_helper'

class ProjectTest < ActionDispatch::IntegrationTest
  include CapyHelper

  setup do
    Capybara.current_driver = Capybara.javascript_driver
    Capybara.default_wait_time = 15
  end

  teardown do
    finish
  end

  test "kate makes a new project" do
    login("kate", "12345")

    # Add a project
    click_on "Projects"
    find('#addProjectButton img').click

    wait_for_id('new_name')

    find('#new_name').set("Das Projekt")
    click_on "Finish"

    assert page.has_content?("Visualizations"),
      "Project page should have 'Visualizations'"

    assert page.has_content?("Logout"),
      "Should be logged in here"

    # Can't use Redactor editor for some reason.
    #find('.add_content_link img').click
    #page.execute_script("$('.redactor_editor').html('All your base...')")
    #find('.redactor_content_save_link').click
    
    click_on "Projects"
    assert page.has_content?("Only Templates"), "Should be on Projects page"
    assert page.has_content?("Das Projekt"), "New project should be in list"

    #click_on "Das Projekt"
    #assert page.has_content?("All your base..."), "Update should have been saved"
  end

  test "search in projects" do
    visit '/'
    click_on "Projects"
    select "Rating", from: "sort"
    fill_in "search", with: "Empty"
    click_on "Search"

    assert page.has_content?("Empty Project")
    assert page.has_no_content?("Breaking Things")
  end
end
