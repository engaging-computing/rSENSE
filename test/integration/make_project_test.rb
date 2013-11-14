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

  test "kate makes a new project" do
    login("kate", "12345")

    # Add a project
    click_on "Projects"
    find('#addProjectButton').click

    wait_for_id('new_name')

    find('#new_name').set("Das Projekt")
    click_on "Finish"

    assert page.has_content?("Visualizations"),
      "Project page should have 'Visualizations'"

    assert page.has_content?("Logout"),
      "Should be logged in here"

    # Get futher with ckEditor than redactor.
    #find('.add_content_link img').click
    #find('.content_holder .content').click
    #find('.cke_button__image_icon').click
    #find('.cke_dialog_tabs [title=Upload]').click

    # Can't get to form in iFrame, so give up on
    # uploading from editor.
    #find('.cke_dialog').click_on "Cancel"

    img_path = Rails.root.join('test', 'CSVs', 'nerdboy.jpg')

    page.execute_script %Q{$('#upload').show()}
    find(".upload_media form").attach_file("upload", img_path)
    #page.execute_script %Q{$('#csv_file_form').submit()}

    assert page.has_content?("nerdboy.jpg"), "File should be in list"

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

    assert page.has_content?("Empty Project"), "Search finds project"
    assert page.has_no_content?("Breaking Things")
  end
end
