require 'test_helper'

class SummernoteMoTest < ActionDispatch::IntegrationTest
  include CapyHelper

  setup do
    Capybara.current_driver = :webkit
    Capybara.default_wait_time = 15
  end
  teardown do
    finish
  end
  
  test 'image_upload' do
    login('kcarcia@cs.uml.edu', '12345')
    visit '/'
    click_on 'Projects'
    click_on 'Create Project'
    find('#project_title').set('Upload Images')
    click_on 'Create'
    assert page.has_content? 'Fields must be set up to contribute data'
    assert page.has_no_css? '.mo_image'
    find('#content-edit-btn').click
    find('.fa-code').click
    find('.note-codable').set('<img src="data:image/gif;base64,R0lGODlhAQABAIAAAHd3dwAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw==" </img>')
    click_on 'Save'
    assert page.has_css? '.mo_image'
    click_on 'Logout'
    login 'nixon@whitehouse.gov', '12345'
    @nixon = users(:nixon)
    #puts @nixon.inspect
    visit '/'
    visit "/users/#{@nixon.id}"
    assert page.has_no_css? '.mo_image'
    page.find('#content-edit-btn').click
    page.find('.fa-code').click
    page.find('.note-codable').set('<img src="data:image/gif;base64,R0lGODlhAQABAIAAAHd3dwAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw==" </img>')
    page.find('#content-save-btn').click
    page.should have_css '.mo_image' 
    #assert page.has_content? '.mo_image'
    #visit '/tutorials'
    #page.find('#tutorial_title').set('Tutorial MO test')
    #click_on 'Create Tutorial'
    #assert page.has_no_css? '.mo_image'
    #page.find('#content-edit-btn').click
    #page.find('.fa-code').click
    #page.find('.note-codable').set('<img src="data:image/gif;base64,R0lGODlhAQABAIAAAHd3dwAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw==" </img>')
    #page.find('#content-save-btn').click
    #expect { page.has_css? '.mo_image' }.to become_true
    #click_on 'Save'
    #assert page.has_css? '.mo_image'
    #click_on 'Logout'
    #login 'nixon@whitehouse.gov', '12345'
    #viz = Visualizations.find(1)
    #viz.content = '<img src="data:image/gif;base64,R0lGODlhAQABAIAAAHd3dwAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw==" </img>'
    #viz.save!
    #visit '/visualizations/1'
    #assert page.has_css? '#viscontainer'
    #page.execute_script "window.scrollBy(0,10000)"
    #page.find('#content-edit-btn').click
    #puts page.html
    #puts request.path
    #page.find('.note-misc').click
    #page.find('.note-codable').set('<img src="data:image/gif;base64,R0lGODlhAQABAIAAAHd3dwAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw==" </img>')
    #click_on 'Save'
    #assert page.has_css? '.mo_image'
    #click_on 'Logout'
  end
end