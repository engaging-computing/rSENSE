require 'test_helper'

class PostNewsTest < ActionDispatch::IntegrationTest
  include CapyHelper

  setup do
    Capybara.current_driver = :webkit
    Capybara.default_wait_time = 15
  end

  teardown do
    finish
  end

  test 'add a news item' do
    login('nixon@whitehouse.gov', '12345')
    assert find('.navbar').has_content?('Richard N.')

    click_on 'News'
    assert page.has_no_content?('The Quick Brown Fox')

    find('#news_title').set('The Quick Green Fox')

    click_on 'Add News Item'
    assert page.has_content?('News entry was successfully created.')
    assert page.has_content?('The Quick Green Fox')

    find('.menu_edit_link').click
    click_on('Edit Title')
    find('#news_title').set('The Quick Brown Fox')
    all('.btn-success').first.click

    sleep 1

    find('#hide_news_checkbox').click

    sleep 1

    visit '/news'

    assert page.has_content?('The Quick Brown Fox'), 'News Was Added'

    logout

    login('kcarcia@cs.uml.edu', '12345')
    click_on 'News'

    assert page.has_no_content?('Add News Item')
    assert page.has_content?('The Quick Brown Fox')
  end
end
