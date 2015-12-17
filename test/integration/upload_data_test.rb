require 'test_helper'
require_relative 'base_integration_test'

class UploadDataTest < IntegrationTest
  self.use_transactional_fixtures = false

  setup do
    @project = projects(:upload_test)
  end

  test 'upload csv' do
    login('kcarcia@cs.uml.edu', '12345')
    visit project_path(@project)
    assert page.has_content?('Upload Test'), 'Not on project page.'

    csv_path = Rails.root.join('test', 'CSVs', 'test.csv')
    find(:css, '#datafile_form').attach_file('file', csv_path)
    assert page.has_content?('Match Quality')
    click_on 'Submit'
    assert page.has_css?('#vis-container'), 'Failed CSV'
  end

  test 'upload gpx' do
    login('kcarcia@cs.uml.edu', '12345')
    visit project_path(@project)
    assert page.has_content?('Upload Test'), 'Not on project page.'

    # Test GPX upload
    gpx_path = Rails.root.join('test', 'CSVs', 'test.gpx')
    find(:css, '#datafile_form').attach_file('file', gpx_path)
    assert page.has_content?('Match Quality')
    all('select')[0].find(:xpath, 'option[1]').select_option
    all('select')[1].find(:xpath, 'option[1]').select_option
    click_on 'Submit'
    assert page.has_css?('#vis-container'), 'Failed GPX'
  end

  test 'upload ods' do
    login('kcarcia@cs.uml.edu', '12345')
    visit project_path(@project)
    assert page.has_content?('Upload Test'), 'Not on project page.'

    # Test ODS upload
    ods_path = Rails.root.join('test', 'CSVs', 'test.ods')
    find(:css, '#datafile_form').attach_file('file', ods_path)
    assert page.has_content?('Match Quality')
    click_on 'Submit'
    assert page.has_css?('#vis-container'), 'Failed ODS'
  end

  test 'upload xls' do
    login('kcarcia@cs.uml.edu', '12345')
    visit project_path(@project)
    assert page.has_content?('Upload Test'), 'Not on project page.'

    # Test XLS upload
    xls_path = Rails.root.join('test', 'CSVs', 'test.xls')
    find(:css, '#datafile_form').attach_file('file', xls_path)
    assert page.has_content?('Match Quality')
    click_on 'Submit'
    assert page.has_css?('#vis-container'), 'Failed XLS'
  end

  test 'upload xlsx' do
    login('kcarcia@cs.uml.edu', '12345')
    visit project_path(@project)
    assert page.has_content?('Upload Test'), 'Not on project page.'

    # Test XLSX upload
    xlsx_path = Rails.root.join('test', 'CSVs', 'test.xlsx')
    find(:css, '#datafile_form').attach_file('file', xlsx_path)
    assert page.has_content?('Match Quality')
    click_on 'Submit'
    assert page.has_css?('#vis-container'), 'Failed XLSX'
  end

  test 'invalid csv (two lat fields)' do
    login('kcarcia@cs.uml.edu', '12345')
    visit project_path(@project)
    assert page.has_content?('Upload Test'), 'Not on project page.'

    csv_path = Rails.root.join('test', 'CSVs', 'invalid_test.csv')
    find(:css, '#datafile_form').attach_file('file', csv_path)

    assert page.has_content?('Error reading file:')
  end

  test 'link google doc' do
    login('kcarcia@cs.uml.edu', '12345')
    visit project_path(@project)
    assert page.has_content?('Upload Test'), 'Not on project page.'

    # Test linking a google doc
    click_on 'Google Doc'
    assert page.has_content? 'Please enter the Google Spreadsheet \'Share\' link below:'
    find(:css, '#doc_url').set('https://docs.google.com/spreadsheet/pub?key=0Aos8U59XvkPkdHI5bmJJaE5tc2xoRVJoaWRNSUp6Q2c&single=true&gid=0&output=csv')
    click_on 'Save'
    assert page.has_content?('Match Quality')
    click_on 'Submit'
    assert page.has_css?('#vis-container'), 'Failed GDOC'
  end

  test 'unreadable file' do
    login('kcarcia@cs.uml.edu', '12345')
    visit project_path(@project)
    assert page.has_content?('Upload Test'), 'Not on project page.'

    # Test upload non-readable
    jpg_path = Rails.root.join('test', 'CSVs', 'nerdboy.jpg')
    find(:css, '#datafile_form').attach_file('file', jpg_path)
    assert page.has_content?('Error reading file:')
  end

  test 'edit data set' do
    login('kcarcia@cs.uml.edu', '12345')
    visit project_path(@project)
    assert page.has_content?('Upload Test'), 'Not on project page.'

    ods_path = Rails.root.join('test', 'CSVs', 'test.ods')
    find(:css, '#datafile_form').attach_file('file', ods_path)
    assert page.has_content?('Match Quality')
    click_on 'Submit'
    assert page.has_css?('#vis-container'), 'Failed ODS'

    visit project_path(@project)

    all('.data_set_edit')[0].click
    assert page.has_content? 'Project:'
    find(:css, '#edit_table_save_2').click
    assert page.has_css?('#vis-container'), 'Data didnt save'
  end

  test 'upload with key' do
    login('kcarcia@cs.uml.edu', '12345')
    visit project_path(@project)
    # Add a student key
    find(:css, '#edit-project-button').click
    fill_in 'Label', with: 'Starbucks'
    fill_in 'Key', with: 'grande'
    click_on 'Create Key'

    click_on 'Back to Project'
    click_on 'Logout'

    # Upload File With Key
    find(:css, '#key').set('grande')
    find(:css, '#contributor_name').set('Bobby D.')
    click_on 'Submit Key'

    csv_path = Rails.root.join('test', 'CSVs', 'test.csv')
    find(:css, '#datafile_form').attach_file('file', csv_path)
    assert page.has_content?('Match Quality'), "Data wasn't submitted"
    fill_in 'Title', with: 'Bad Data'

    click_on 'Submit'
    assert page.has_content?('Bad Data')
  end

  test 'display users name not contributor name' do
    login('kcarcia@cs.uml.edu', '12345')
    visit project_path(@project)
    # Add a key
    find(:css, '#edit-project-button').click
    fill_in 'Label', with: 'Starbucks'
    fill_in 'Key', with: 'grande'
    click_on 'Create Key'

    click_on 'Back to Project'
    click_on 'Logout'

    # Enter Key
    find(:css, '#key').set('grande')
    find(:css, '#contributor_name').set('Bobby D.')
    click_on 'Submit Key'

    # Log back in and upload data
    login('kcarcia@cs.uml.edu', '12345')
    visit project_path(@project)
    csv_path = Rails.root.join('test', 'CSVs', 'test.csv')
    find(:css, '#datafile_form').attach_file('file', csv_path)
    assert page.has_content?('Match Quality'), "Data wasn't submitted"
    fill_in 'Title', with: 'My Data'
    click_on 'Submit'

    # Check that data uploaded
    assert page.has_content?('My Data')

    # Check that the name is the users name and not the contributer name
    # that was entered before logging in
    visit project_path(@project)
    assert page.has_no_content?('Bobby D.')
  end
end
