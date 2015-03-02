require 'test_helper'

class EditProjDescTest < ActionDispatch::IntegrationTest
  include CapyHelper

  self.use_transactional_fixtures = false

  setup do
    @project = projects(:description_test)
    Capybara.current_driver = :webkit
    Capybara.default_wait_time = 15
  end

  teardown do
    finish
  end

  test 'nav on no desc edit' do
    login('kcarcia@cs.uml.edu', '12345')
    visit project_path(@project)
    assert page.has_content?('Goat'), 'Not on project page.'

    # confirm you can leave the project page
    find('#edit-project-button').click
    assert page.has_content?('Back to Project'), 'Not on edit page.'
  end

  test 'nav on edit desc no changes' do
    login('kcarcia@cs.uml.edu', '12345')
    visit project_path(@project)
    assert page.has_content?('Goat'), 'Not on project page.'

    # click the description but do not add text to it
    find('#content-edit-btn').click

    # confirm can navigate away from page
    find('#manual_fields').click
    assert page.has_css?('.fields_table'), 'Not on manual entry page.'
  end

  test 'nav on edit desc and cancel' do
    login('kcarcia@cs.uml.edu', '12345')
    visit project_path(@project)
    assert page.has_content?('Goat'), 'Not on project page.'

    # start typing a description and confirm the text exists
    find('#content-edit-btn').click
    find('.note-editable').set('arbitrary')
    assert page.has_content?('arbitrary'), 'No description added.'

    # cancel the description, confirm it is gone, and confirm navigation away
    find('#content-cancel-btn').click
    assert page.has_no_content?('aritrary'), 'Description should be gone.'
    find('#manual_fields').click
    assert page.has_css?('.fields_table'), 'Not on manual entry page.'
  end

  test 'nav on edit desc and save' do
    login('kcarcia@cs.uml.edu', '12345')
    visit project_path(@project)
    assert page.has_content?('Goat'), 'Not on project page.'

    # start typing a description and confirm the text exists
    find('#content-edit-btn').click
    find('.note-editable').set('more arbitrary')
    assert page.has_content?('more arbitrary'), 'No description added.'

    # save the description, confirm nav back to project with the new description
    find('#content-save-btn').click
    assert page.has_content?('Goat'), 'Not on project page.'
    assert page.has_content?('more arbitrary'), 'Description not saved.'

    # confirm can navigate away from project page
    find('#edit-project-button').click
    assert page.has_content?('Back to Project'), 'Not on edit page.'
  end

  test 'shouldnt nav on edit desc and leave' do
    login('kcarcia@cs.uml.edu', '12345')
    visit project_path(@project)
    assert page.has_content?('Goat'), 'Not on project page.'

    # start typing a description and confirm the text exists
    find('#content-edit-btn').click
    find('.note-editable').set('arbitrary wow')
    assert page.has_content?('arbitrary wow'), 'No description added.'

    # without saving, try navigating away - should be stopped by a JS pop-up
    page.driver.browser.reject_js_confirms
    find('#edit-project-button').click
    assert page.has_no_content?('Back to Project'), 'Shouldnt be on edit page.'

    # without saving, try refreshing - should still be stopped by JS pop-up
    visit current_path
    assert page.has_content?('Goat'), 'Not on project page.'

    # now accept the JS navigation and confirm we left the project page
    page.driver.browser.accept_js_confirms
    find('#edit-project-button').click
    assert page.has_content?('Back to Project'), 'Should be on edit page.'
  end
end
