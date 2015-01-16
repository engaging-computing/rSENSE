require 'test_helper'

class SlickgridTest < ActionDispatch::IntegrationTest
  include CapyHelper

  self.use_transactional_fixtures = true

  setup do
    Capybara.current_driver = :selenium
  end

  teardown do
    finish
  end

  def slickgrid_enter_value(row, col, value)
    find(:css, ".slick-row:nth-child(#{row + 1})>.slick-cell.l#{col}").click
    find(:css, ".slick-row:nth-child(#{row + 1})>.slick-cell.l#{col}>input").set value
  end

  def slickgrid_choose(row, col, option)
    find(:css, ".slick-row:nth-child(#{row + 1})>.slick-cell.l#{col}").click
    find(:css, ".slick-row:nth-child(#{row + 1})>.slick-cell.l#{col}>select>option:nth-child(#{option + 1})").select_option
  end

  def slickgrid_set_date(row, col, yr, mo, dy, hr, mi, se)
    find(:css, ".slick-row:nth-child(#{row + 1})>.slick-cell.l#{col}").click
    find(:css, '#dt-year-textbox').set "#{yr}\n"
    find(:css, '#dt-month-textbox').click
    find(:css, "#dt-month-select>option:nth-child(#{mo})").select_option
    td = all(:css, '#dt-date-group td')
    td.select { |x| x['data-date'.to_sym] == "#{dy}" and x['data-month'.to_sym] == "#{mo - 1}" }.first.click
    find(:css, '#dt-time-textbox').set "#{hr}:#{mi}:#{se}\n"
  end

  test 'slickgrid manual entry' do
  end

  test 'slickgrid edit dataset' do
    login 'nixon@whitehouse.gov', '12345'

    dataset = DataSet.find_by_name('Slickgrid Dataset 1').id
    visit"/data_sets/#{dataset}/edit"

    # assert presence of column headers
    assert page.has_content? 'text_field'
    assert page.has_content? 'restrictions_field'
    assert page.has_content? 'number_field'
    assert page.has_content? 'timestamp_field'
    assert page.has_content? 'latitude_field & longitude_field'

    # assert presence of data
    page.assert_selector '.slick-row', count: 3
    assert page.has_content? '0, 0'
    assert page.has_content? '1, 1'
    assert page.has_content? '2, 2'

    # build a map of field ids to columns
    fields = all :css, '.slick-header-column'
    field_map = {}
    fields.each.with_index { |x, i| field_map[x[:id][-3..-1]] = i }

    # add some rows
    button = find :css, '#edit_table_add_1'
    4.times { button.click }

    # assert rows were actually added
    page.assert_selector '.slick-row', count: 7

    # add data to those rows
    slickgrid_enter_value 3, field_map['100'], 'D'
    slickgrid_enter_value 4, field_map['100'], 'E'
    slickgrid_enter_value 5, field_map['100'], 'F'
    slickgrid_enter_value 6, field_map['100'], 'G'

    slickgrid_choose 3, field_map['101'], 0
    slickgrid_choose 4, field_map['101'], 1
    slickgrid_choose 5, field_map['101'], 2
    slickgrid_choose 6, field_map['101'], 0

    slickgrid_enter_value 3, field_map['102'], '4'
    slickgrid_enter_value 4, field_map['102'], '5'
    slickgrid_enter_value 5, field_map['102'], '6'
    slickgrid_enter_value 6, field_map['102'], '7'

    slickgrid_set_date 3, field_map['103'], 1991, 1, 1, 1, 1, 1
    slickgrid_set_date 4, field_map['103'], 1992, 2, 2, 2, 2, 2
    slickgrid_set_date 5, field_map['103'], 1993, 3, 3, 3, 3, 3
    slickgrid_set_date 6, field_map['103'], 1994, 4, 4, 4, 4, 4

    slickgrid_enter_value 3, field_map['105'], '3, 3'
    slickgrid_enter_value 4, field_map['105'], '4, 4'
    slickgrid_enter_value 5, field_map['105'], '5, 5'
    slickgrid_enter_value 6, field_map['105'], '6, 6'

    # delete some rows
    find(:css, '.slick-row:nth-child(3) .slick-delete').click
    find(:css, '.slick-row:nth-child(2) .slick-delete').click
    find(:css, '.slick-row:nth-child(1) .slick-delete').click

    # assert correct rows were deleted

    # save the dataset

    # assert that the dataset was saved properly
  end
end
