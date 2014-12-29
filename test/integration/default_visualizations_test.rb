require 'test_helper'

class DefaultVisualizationTest < ActionDispatch::IntegrationTest
  include CapyHelper
  test 'default visualization test' do
    login('kcarcia@cs.uml.edu', '12345')
    assert page.has_content? 'Kate'
    visit '/'
    click_on 'Projects'
    assert page.has_content? 'Dessert is Delicious'
    click_on 'Dessert is Delicious'
    assert page.has_content? 'Data Sets'
    click_on 'Thanksgiving Dinner'
    #find_by_id('vis_button').click
    assert page.has_content? 'Media'
  	assert page.has_content? 'Dessert is Delicious'
  	find_by_id('table_canvas').click
  	puts find_by_id('table_canvas')['aria-']
  end
end