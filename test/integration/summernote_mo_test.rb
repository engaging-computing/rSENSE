require 'test_helper'
require_relative 'base_integration_test'

class SummernoteMoTest < IntegrationTest
  include CapyHelper

  self.use_transactional_fixtures = false

  test 'project_image_upload' do
    login('kcarcia@cs.uml.edu', '12345')
    visit '/'
    click_on 'Projects'
    find('#create-project-fab-button').click
    find(:css, '#project_title').set('Upload Images SNMO')
    click_on 'Create Project'
    assert page.has_content? 'Fields must be set up to contribute data'
    assert page.has_no_css? '.mo_image'

    find(:css, '#add-content-image').click
    find(:css, '.fa-code').find(:xpath, '..').click
    find(:css, '.note-codable').set('<img src="data:image/gif;base64,R0lGODlhAQABAIAAAHd3dwAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw==" </img>')
    click_on 'Save'
    assert page.has_css? '.mo_image'
    click_on 'Logout'
    assert page.has_css? '.mo_image'
  end

  test 'user_image_upload' do
    login('nixon@whitehouse.gov', '12345')
    find(:css, '.navbar-right > #username').click
    assert page.has_css? '.gravatar_img', 'Not on profile page.'
    find(:css, '#add-content-image').click
    find(:css, '.fa-code').find(:xpath, '..').click
    find(:css, '.note-codable').set('<img src="data:image/gif;base64,R0lGODlhAQABAIAAAHd3dwAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw==" </img>')
    click_on 'Save'
    assert !(page.find(:css, '#content-viewer').find(:css, 'img')[:src].include? 'data:image')
    click_on 'Logout'
  end

  test 'news_image_upload' do
    login('nixon@whitehouse.gov', '12345')
    visit '/news'
    page.find(:css, '#news_title').set('Test News Article SNMO')
    click_on 'Add News Item'
    assert page.has_content? 'News entry was successfully created.'
    assert page.has_no_css? '.mo_image'
    find(:css, '#add-content-image').click
    find(:css, '.fa-code').find(:xpath, '..').click
    find(:css, '.note-codable').set('<img src="data:image/gif;base64,R0lGODlhAQABAIAAAHd3dwAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw==" </img>')
    click_on 'Save'
    assert page.has_css? '.mo_image'
    click_on 'Logout'
  end
end
