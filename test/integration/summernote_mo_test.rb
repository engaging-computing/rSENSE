require 'test_helper'

class SummernoteMoTest < ActionDispatch::IntegrationTest
  include CapyHelper

  self.use_transactional_fixtures = false

  setup do
    Capybara.current_driver = :webkit
  end
  teardown do
    finish
  end

  test 'project_image_upload' do
    login('kcarcia@cs.uml.edu', '12345')
    visit '/'
    click_on 'Projects'
    click_on 'Create Project'
    find('#project_title').set('Upload Images SNMO')
    click_on 'Create'
    assert page.has_content? 'Fields must be set up to contribute data'
    assert page.has_no_css? '.mo_image'

    find('#content-edit-btn').click
    find('.fa-code').find(:xpath, '..').click
    find('.note-codable').set('<img src="data:image/gif;base64,R0lGODlhAQABAIAAAHd3dwAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw==" </img>')
    click_on 'Save'
    assert page.has_css? '.mo_image'
    click_on 'Logout'
    assert page.has_css? '.mo_image'

  end

  test 'tutorial_image_upload' do
    login 'nixon@whitehouse.gov', '12345'
    visit '/tutorials'
    find('#tutorial_title').set('Test Tutorial SNMO')
    click_on 'Create Tutorial'
    assert page.has_no_css? '.mo_image'
    find('#content-edit-btn').click
    find('.fa-code').find(:xpath, '..').click
    find('.note-codable').set('<img src="data:image/gif;base64,R0lGODlhAQABAIAAAHd3dwAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw==" </img>')
    click_on 'Save'
    assert page.has_css? '.mo_image'
    click_on 'Logout'
  end

  test 'user_image_upload' do
    login 'nixon@whitehouse.gov', '12345'
    click_on 'Richard N.'
    assert page.has_css? '.gravatar_img', 'Not on profile page.'
    find('#content-edit-btn').click
    find('.fa-code').find(:xpath, '..').click
    find('.note-codable').set('<img src="data:image/gif;base64,R0lGODlhAQABAIAAAHd3dwAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw==" </img>')
    click_on 'Save'
    assert !(page.find('#content-viewer').find('img')[:src].include? 'data:image')
    click_on 'Logout'
  end

  test 'news_image_upload' do
    login 'nixon@whitehouse.gov', '12345'
    visit '/news'
    page.find('#news_title').set('Test News Article SNMO')
    click_on 'Add News Item'
    assert page.has_content? 'News entry was successfully created.'
    assert page.has_no_css? '.mo_image'
    find('#content-edit-btn').click
    find('.fa-code').find(:xpath, '..').click
    find('.note-codable').set('<img src="data:image/gif;base64,R0lGODlhAQABAIAAAHd3dwAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw==" </img>')
    click_on 'Save'
    assert page.has_css? '.mo_image'
    click_on 'Logout'
  end
end
