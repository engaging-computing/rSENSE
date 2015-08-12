require 'test_helper'

class UserSortingTest < ActionDispatch::IntegrationTest
  include CapyHelper

  setup do
    Capybara.current_driver = :webkit
    Capybara.default_wait_time = 2
  end

  teardown do
    finish
  end

  test 'use sorting' do
    # Navigate to the user's page
    login('kcarcia@cs.uml.edu', '12345')
    find(:css, '#username').click

    # Assert that the default sort mode is creation date, descending
    sort_method = find(:css, '#contribution_sort', visible: false)[:value]
    assert_equal 'create dsc', sort_method

    # Assert that the newest project is first
    assert_equal 'Breaking Things', find(:css, 'tr:first-child > td:first-child').text

    # Sort by date ascending and assert that the oldest project is first
    find(:css, 'thead > tr > th:nth-child(2)').click
    wait_for_ajax
    assert_equal 'Empty Project', find(:css, 'tr:first-child > td:first-child').text

    # Sort by name ascending and assert things
    find(:css, 'thead > tr > th:nth-child(1)').click
    wait_for_ajax
    assert_equal 'Breaking Things', find(:css, 'tr:first-child > td:first-child').text

    # Sort by name descending and assert things
    find(:css, 'thead > tr > th:nth-child(1)').click
    wait_for_ajax
    assert_equal 'Upload Test', find(:css, 'tr:first-child > td:first-child').text

    # Switch to data sets tab, assert that we're still sorting by name descending
    find(:css, 'ul#user_filter > li:nth-child(2)').click
    wait_for_ajax
    assert_equal 'Thanksgiving Dinner', find(:css, 'tr:first-child > td:first-child').text

    # Switch to visualizations tab, assert that we're still sorting by name descending
    find(:css, 'ul#user_filter > li:nth-child(3)').click
    wait_for_ajax
    assert_equal 'VisualizationTitle1', find(:css, 'tr:first-child > td:first-child').text

    # Switch to likes tab, test case where there are no results
    find(:css, 'ul#user_filter > li:nth-child(4)').click
    wait_for_ajax
    assert_equal 'No Results', find(:css, '#pageLabel').text
  end
end
