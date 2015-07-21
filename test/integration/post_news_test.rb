require 'test_helper'

class PostNewsTest < ActionDispatch::IntegrationTest
  include CapyHelper

  self.use_transactional_fixtures = false

  setup do
    @unpublished = news(:unpublished_news)
    @to_rename = news(:rename_this_news)
    @to_delete = news(:delete_this_news)
    @to_update = news(:update_this_news)
    Capybara.current_driver = :webkit
    Capybara.default_wait_time = 2
  end

  teardown do
    finish
  end

  test 'add a news item' do
    login('nixon@whitehouse.gov', '12345')

    click_on 'News'
    assert page.has_no_content?('New news item #1'), 'News item should not exist'

    find('#news_title').set('New news item #1')
    click_on 'Add News Item'
    assert page.has_content?('News entry was successfully created.')

    logout
    visit '/'
    login('kcarcia@cs.uml.edu', '12345')
    click_on 'News'
    assert page.has_no_content?('New news item #1'), 'News was not published, should not be shown.'
  end

  test 'publish news' do
    login('kcarcia@cs.uml.edu', '12345')
    click_on 'News'
    assert page.has_no_content?('Unpublished News'), 'News was not published, should not be shown.'

    logout
    visit '/'
    login('nixon@whitehouse.gov', '12345')
    visit news_path(@unpublished)
    assert page.has_content?('Unpublished News'), 'Not on the news page'

    find('#hide_news_checkbox').click
    sleep 1

    logout
    visit '/'
    login('kcarcia@cs.uml.edu', '12345')
    click_on 'News'
    assert page.has_content?('Unpublished News'), 'News was published, should be shown.'
  end

  test 'rename news' do
    login('nixon@whitehouse.gov', '12345')
    visit news_path(@to_rename)
    assert page.has_content?('To be renamed'), 'Not on the right page'

    find('.menu_edit_link').click
    find('.menu_rename').click
    find('#news_title').set 'Changed'
    find('.fa-floppy-o').click

    assert page.has_content?('News was successfully updated.'), 'Failed to update title'
    assert page.has_content?('Changed'), 'Title should be changed'
  end

  test 'delete news' do
    login('nixon@whitehouse.gov', '12345')
    visit news_path(@to_delete)
    assert page.has_content?('To be deleted'), 'Not on the right page'

    find('.menu_edit_link').click
    find('.menu_delete').click
    page.driver.browser.accept_js_confirms

    assert page.has_no_content?('To be deleted'), 'News was not deleted'
  end

  test 'add summary to news' do
    login('nixon@whitehouse.gov', '12345')
    visit news_path(@to_update)
    assert page.has_content?('To be updated'), 'Not on the right page'

    find('.menu_edit_link').click
    find('.summary_edit').click
    find('#news_summary').set 'Updated to have a summary'
    find('.fa-floppy-o').click

    assert page.has_content?('News was successfully updated.'), 'Failed to update summary'
    assert page.has_content?('Updated to have a summary'), 'Title should be changed'
  end
end
