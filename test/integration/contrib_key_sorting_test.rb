require 'test_helper'

class ContribKeySortingTest < ActionDispatch::IntegrationTest
  include CapyHelper

  setup do
    Capybara.current_driver = :webkit
    Capybara.default_wait_time = 15
  end

  teardown do
    finish
  end
  
  #setup
  setup do
    
    visit('/')
    login('jkinsman1986@gmail.com', 'G1adiator')
    click_on 'Projects'
    click_on 'Create Project'
    find('#project_title').set('Contributor Key Test Project')
    click_on 'Submit'
    assert page.has_content? 'Visualizations'
  end

end
