require 'test_helper'

class UploadDataTest < ActionDispatch::IntegrationTest
  include CapyHelper

  setup do
    Capybara.current_driver = :webkit
    Capybara.default_wait_time = 15
  end

  teardown do
    finish
  end

  test 'upload all filetypes' do
    login('kcarcia@cs.uml.edu', '12345')

    # Add a project
    click_on 'Projects'
    click_on 'Create Project'
    assert page.has_content?('What would you like to name your project?')
    find('#project_title').set('File Types')
    click_on 'Create'
    assert page.has_content?('Fields'), "Project page should have 'Fields'"

    # Test CSV upload by creating fields
    # find('#template_file_upload').click
    csv_path = Rails.root.join('test', 'CSVs', 'test.csv')
    page.execute_script "$('#template_file_form').parent().show()"
    find('#template_file_form').attach_file('file', csv_path)
    page.execute_script "$('#template_file_form').submit()"
    assert page.has_content?('Please select types for each field below.')
    all('select')[0].find(:xpath, 'option[4]').select_option
    all('select')[1].find(:xpath, 'option[5]').select_option
    click_on 'Submit'
    assert page.has_content?('Dataset #1'), 'Failed CSV'
    click_on 'File Types'
    assert page.has_content?('Contribute Data')

    # Test GPX upload
    gpx_path = Rails.root.join('test', 'CSVs', 'test.gpx')
    page.execute_script "$('#datafile_form').parent().show()"
    find('#datafile_form').attach_file('file', gpx_path)
    page.execute_script "$('#datafile_form').submit()"
    assert page.has_content?('Match Quality')
    all('select')[0].find(:xpath, 'option[1]').select_option
    all('select')[1].find(:xpath, 'option[1]').select_option
    click_on 'Submit'
    assert page.has_content?('Dataset #2'), 'Failed GPX'
    click_on 'File Types'
    assert page.has_content?('Contribute Data')

    # Test ODS upload
    ods_path = Rails.root.join('test', 'CSVs', 'test.ods')
    page.execute_script "$('#datafile_form').parent().show()"
    find('#datafile_form').attach_file('file', ods_path)
    page.execute_script "$('#datafile_form').submit()"
    assert page.has_content?('Match Quality')
    click_on 'Submit'
    assert page.has_content?('Dataset #3'), 'Failed ODS'
    click_on 'File Types'
    assert page.has_content?('Contribute Data')

    # Test XLS upload
    xls_path = Rails.root.join('test', 'CSVs', 'test.xls')
    page.execute_script "$('#datafile_form').parent().show()"
    find('#datafile_form').attach_file('file', xls_path)
    page.execute_script "$('#datafile_form').submit()"
    assert page.has_content?('Match Quality')
    click_on 'Submit'
    assert page.has_content?('Dataset #4'), 'Failed XLS'
    click_on 'File Types'
    assert page.has_content?('Contribute Data')

    # Test XLSX upload
    xlsx_path = Rails.root.join('test', 'CSVs', 'test.xlsx')
    page.execute_script "$('#datafile_form').parent().show()"
    find('#datafile_form').attach_file('file', xlsx_path)
    page.execute_script "$('#datafile_form').submit()"
    assert page.has_content?('Match Quality')
    click_on 'Submit'
    assert page.has_content?('Dataset #5'), 'Failed XLSX'
    click_on 'File Types'
    assert page.has_content?('Contribute Data')

    # Test linking a google doc
    click_on 'Google Doc'
    assert page.has_content? 'Please enter the Google Drive link to share below:'
    find('#doc_url').set('https://docs.google.com/spreadsheet/pub?key=0Aos8U59XvkPkdHI5bmJJaE5tc2xoRVJoaWRNSUp6Q2c&single=true&gid=0&output=csv')
    click_on 'Save'
    assert page.has_content?('Match Quality')
    click_on 'Submit'
    assert page.has_content?('Dataset #6'), 'Failed GDOC'
    click_on 'File Types'
    assert page.has_content?('Contribute Data')

    # Test upload non-readable
    jpg_path = Rails.root.join('test', 'CSVs', 'nerdboy.jpg')
    page.execute_script "$('#datafile_form').parent().show()"
    find('#datafile_form').attach_file('file', jpg_path)
    assert page.has_content?('File could not be read')

    # Test edit data set
    all('.data_set_edit')[0].click
    assert page.has_content? 'Project:'
    find('#edit_table_save').click
    assert page.has_content?('Save Visualization'), 'Save Viz Button'

    click_on 'File Types'
    assert page.has_content?('Contribute Data')

    # Test Saved Vis
    proj_url = current_url
    click_on 'Dataset #1'
    ds_url = current_url
    # Tests visual modes for dataset viewing
    visit ds_url + '?presentation=true'
    assert page.has_no_content?('Saved Vis - File Types')
    assert page.has_no_content?('Groups')
    visit ds_url + '?embed=true'
    assert page.has_no_content?('Saved Vis - File Types')
    assert page.has_content?('Groups')

    # Tests visual modes for saved vis
    visit ds_url
    click_on 'Histogram'
    click_on 'Save Visualization'
    click_on 'Finish'
    assert page.has_content?('Saved Vis - File Types')
    vis_url = current_url
    visit vis_url + '?presentation=true'
    assert page.has_no_content?('Saved Vis - File Types')
    assert page.has_no_content?('Groups')
    visit vis_url + '?embed=true'
    assert page.has_no_content?('Saved Vis - File Types')
    assert page.has_content?('Groups')
    visit vis_url

    page.execute_script 'window.confirm = function () { return true }'

    # Tests deleting vises
    click_on 'Visualizations'
    assert page.has_content?('Saved Vis - File Types')
    visit vis_url
    find('.menu_edit_link').click
    click_on 'Delete Visualization'
    # Capybara-webkit needs the window.confirm hack instead
    # page.driver.browser.switch_to.alert.accept
    assert page.has_no_content?('Saved Vis - File Types')
    visit proj_url
    assert page.has_no_content?('Saved Vis - File Types')
    assert page.has_content?('Contribute Data')

    # Add a student key
    find('#edit-project-button').click
    fill_in 'Label', with: 'Starbucks'
    fill_in 'Key', with: 'grande'
    click_on 'Create Key'

    click_on 'Back to Project'
    click_on 'Logout'

    # Upload File With Key
    find('#key').set('grande')
    click_on 'Submit Key'

    csv_path = Rails.root.join('test', 'CSVs', 'test.csv')
    page.execute_script "$('#datafile_form').parent().show()"
    find('#datafile_form').attach_file('file', csv_path)
    page.execute_script "$('#datafile_form').submit()"
    assert page.has_content?('Match Quality'), "Data wasn't submitted"
    fill_in 'Title', with: 'Bad Data'
    fill_in 'Your Name', with: 'Jim D.'
    click_on 'Submit'
    assert page.has_content?('Bad Data - Jim D.')
    click_on 'File Types'
    assert page.has_content?('Contribute Data')
  end
end
