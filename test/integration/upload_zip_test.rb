require 'test_helper'
require_relative 'base_integration_test'

class UploadZipTest < IntegrationTest
  self.use_transactional_fixtures = false

  setup do
    @project = projects(:one)
  end

  test 'upload zip with csv files' do
    login('kcarcia@cs.uml.edu', '12345')
    visit project_path(@project)
    assert page.has_content?('one'), 'Not on project page.'

    zip_path = Rails.root.join('test', 'CSVs', 'upload.zip')
    begin
      page.execute_script "$('#datafile_form').parent().show()"
    rescue => e
      puts e.inspect
    end
    find('#datafile_form').attach_file('file', zip_path)
    begin
      page.execute_script "$('#datafile_form').submit()"
    rescue => e
      puts e.inspect
    end
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

    zip_path = Rails.root.join('test', 'CSVs', 'img.zip')
    page.execute_script "$('#datafile_form').parent().show()"
    find('#datafile_form').attach_file('file', zip_path)
    page.execute_script "$('#datafile_form').submit()"
    assert page.has_content?('Error reading file')
  end
end
