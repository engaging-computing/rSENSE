require 'test_helper'

class UploadZipTest < ActionDispatch::IntegrationTest
  include CapyHelper

  self.use_transactional_fixtures = false

  setup do
    @project = projects(:one)
    Capybara.current_driver = :webkit
    Capybara.default_wait_time = 15
  end

  teardown do
    finish
  end

  test 'upload csv' do
    login('kcarcia@cs.uml.edu', '12345')
    visit project_path(@project)
    assert page.has_content?('one'), 'Not on project page.'

    zip_path = Rails.root.join('test', 'CSVs', 'upload_zip.zip')
    page.execute_script "$('#datafile_form').parent().show()"
    find('#datafile_form').attach_file('file', zip_path)
    page.execute_script "$('#datafile_form').submit()"
    assert page.has_content?('Match Quality')
    click_on 'Submit'
    assert page.has_content?('one'), 'Not on project page after upload.'
    assert page.has_content?('first'), 'First Dataset not uploaded.'
    assert page.has_content?('second'), 'Second Dataset not uploaded.'
  end

  test 'upload bad csv with image' do
    login('kcarcia@cs.uml.edu', '12345')
    visit project_path(@project)
    assert page.has_content?('one'), 'Not on project page.'

    zip_path = Rails.root.join('test', 'CSVs', 'bad_with_image.zip')
    page.execute_script "$('#datafile_form').parent().show()"
    find('#datafile_form').attach_file('file', zip_path)
    page.execute_script "$('#datafile_form').submit()"
    assert page.has_content?('Error reading file')
    click_on 'Submit'
  end
end