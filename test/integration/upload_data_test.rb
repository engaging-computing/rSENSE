require 'test_helper'

class EnterDataSetTest < ActionDispatch::IntegrationTest
  include CapyHelper

  setup do
    Capybara.current_driver = Capybara.javascript_driver
    Capybara.default_wait_time = 15
  end

  teardown do
    finish
  end
  
  test "upload all filetypes" do
    login("kate", "12345")

    # Add a project
    click_on "Projects"
    find('#addProjectButton').click
    wait_for_id('new_name')
    find('#new_name').set("File Types")
    click_on "Finish"
    assert page.has_content?("Fields"), "Project page should have 'Fields'"
    
    # Test CSV upload by creating fields
    #find('#template_file_upload').click
    csv_path = Rails.root.join('test', 'CSVs', 'test.csv')
    page.execute_script %Q{$('#template_file_form').parent().show()}
    find("#template_file_form").attach_file("file",csv_path)
    page.execute_script %Q{$('#template_file_form').submit()}
    assert page.has_content?("Please select types for each field below.")
    all('select')[0].find(:xpath, 'option[4]').select_option
    all('select')[1].find(:xpath, 'option[5]').select_option
    click_on "Submit"
    assert page.has_content?("Dataset #1")
    click_on "File Types"
    assert page.has_content?("Contribute Data")

    # Test GPX upload
    gpx_path = Rails.root.join('test', 'CSVs', 'test.gpx')
    page.execute_script %Q{$('#datafile_form').parent().show()}
    find("#datafile_form").attach_file("file",gpx_path)
    page.execute_script %Q{$('#datafile_form').submit()}
    assert page.has_content?("Match Quality")
    click_on "Submit"
    assert page.has_content?("Dataset #2")
    click_on "File Types"
    assert page.has_content?("Contribute Data")

    # Test ODS upload
    ods_path = Rails.root.join('test', 'CSVs', 'test.ods')
    page.execute_script %Q{$('#datafile_form').parent().show()}
    find("#datafile_form").attach_file("file",ods_path)
    page.execute_script %Q{$('#datafile_form').submit()}
    assert page.has_content?("Match Quality")
    click_on "Submit"
    assert page.has_content?("Dataset #3")
    click_on "File Types"
    assert page.has_content?("Contribute Data")

    # Test XLS upload
    xls_path = Rails.root.join('test', 'CSVs', 'test.xls')
    page.execute_script %Q{$('#datafile_form').parent().show()}
    find("#datafile_form").attach_file("file",xls_path)
    page.execute_script %Q{$('#datafile_form').submit()}
    assert page.has_content?("Match Quality")
    click_on "Submit"
    assert page.has_content?("Dataset #4")
    click_on "File Types"
    assert page.has_content?("Contribute Data")
     
    # Test XLSX upload
    xlsx_path = Rails.root.join('test', 'CSVs', 'test.xlsx')
    page.execute_script %Q{$('#datafile_form').parent().show()}
    find("#datafile_form").attach_file("file",xlsx_path)
    page.execute_script %Q{$('#datafile_form').submit()}
    assert page.has_content?("Match Quality")
    click_on "Submit"
    assert page.has_content?("Dataset #5")
    click_on "File Types"
    assert page.has_content?("Contribute Data")

    # Test upload non-readable
    jpg_path = Rails.root.join('test', 'CSVs', 'nerdboy.jpg')
    page.execute_script %Q{$('#datafile_form').parent().show()}
    find("#datafile_form").attach_file("file",jpg_path)
    assert page.has_content?("File could not be read")
    
    #Test edit data set
    all(".data_set_edit")[0].click
    assert page.has_content? "Project:"
    find('#edit_table_save').click
    assert page.has_content?("Save Visualization")
    click_on "File Types"
    assert page.has_content?("Contribute Data")
    
    # Test Saved Vis
    proj_url = current_url
    click_on "Dataset #1"
    ds_url = current_url
    # Tests visual modes for dataset viewing
    visit ds_url + "?presentation=true"
    assert page.has_no_content?("Saved Vis - File Types")
    assert page.has_no_content?("Groups")
    visit ds_url + "?embed=true"
    assert page.has_no_content?("Saved Vis - File Types")
    assert page.has_content?("Groups")
    # Tests visual modes for saved vis
    visit ds_url
    click_on "Histogram"
    click_on "Save Visualization"
    click_on "Finish"
    assert page.has_content?("Saved Vis - File Types")
    vis_url = current_url
    visit vis_url + "?presentation=true"
    assert page.has_no_content?("Saved Vis - File Types")
    assert page.has_no_content?("Groups")
    visit vis_url + "?embed=true"
    assert page.has_no_content?("Saved Vis - File Types")
    assert page.has_content?("Groups")
    visit vis_url
    # Tests deleting vises
    click_on "Visualizations"
    assert page.has_content?("Saved Vis - File Types")
    visit vis_url
    find('.menu_edit_link').click
    click_on "Delete Visualization"
    page.driver.browser.switch_to.alert.accept
    assert page.has_no_content?("Saved Vis - File Types")
    visit proj_url
    assert page.has_no_content?("Saved Vis - File Types")
    assert page.has_content?("Contribute Data")
  end
end
