require 'test_helper'

class ManualEntryTest < ActionDispatch::IntegrationTest
  include CapyHelper

  setup do
    Capybara.current_driver = :webkit
    Capybara.default_wait_time = 15
  end

  teardown do
    finish
  end

  def set_cell(ii, val)
    page.execute_script "$($('#manualTable input')[#{ii}]).val(#{val})"
  end

  test 'manual entry of datasets' do
    login('kcarcia@cs.uml.edu', '12345')
    visit('/')
    click_on 'Projects'
    click_on 'Dessert is Delicious'
    click_on 'Manual Entry'

    fill_in 'Dataset Name', with: 'I Like Cookies'
    click_on 'Add Row'

    set_cell(0, 29)
    set_cell(1, 0)
    set_cell(2, 0)
    set_cell(3, 24)
    set_cell(4, 0)
    set_cell(5, 1)

    click_on 'Save'

    assert page.has_content?('I Like Cookies'), 'Dataset Name'

    click_on 'Dessert is Delicious'

    find('.project_info_box .btn-primary').click
    fill_in 'Label', with: 'Test Key'
    fill_in 'Key', with: 'strong bad'
    click_on 'Create Key'

    logout

    visit('/')
    click_on 'Projects'
    click_on 'Dessert is Delicious'

    find('#key').set('strong bad')
    click_on 'Submit Key'

    click_on 'Manual Entry'

    fill_in 'Dataset Name', with: 'I Like Pies'
    click_on 'Add Row'

    set_cell(0, 1)
    set_cell(1, 3)
    set_cell(2, 377)
    set_cell(3, 24)
    set_cell(4, 0)
    set_cell(5, 1027)

    click_on 'Save'

    assert page.has_content?('I Like Pies'), 'Dataset Name'
  end
end
