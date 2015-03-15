require 'test_helper'

class SlickgridTest < ActionDispatch::IntegrationTest
  include CapyHelper

  self.use_transactional_fixtures = false

  current_month = Date.today.month.to_s.rjust(2, '0')
  compare_data = [
    { '100' => 'D', '101' => 'A', '102' => '4', '103' => "1991/#{current_month}/01 01:01:01", '104' => '3', '105' => '3' },
    { '100' => 'E', '101' => 'B', '102' => '5', '103' => "1992/#{current_month}/02 02:02:02", '104' => '4', '105' => '4' },
    { '100' => 'F', '101' => 'C', '102' => '6', '103' => "1993/#{current_month}/03 03:03:03", '104' => '5', '105' => '5' },
    { '100' => 'G', '101' => 'A', '102' => '7', '103' => "1994/#{current_month}/04 04:04:04", '104' => '6', '105' => '6' }
  ]

  setup do
    Capybara.current_driver = :webkit
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

  def slickgrid_set_date(row, col, options)
    yr = options[:year]
    dy = options[:day]
    time = options[:time]

    find(:css, ".slick-row:nth-child(#{row + 1})>.slick-cell.l#{col}").click
    find(:css, '.editor-button').click
    find(:css, '#dt-year-textbox').set "#{yr}\n"
    td = all(:css, '#dt-date-group td')
    date_cell = td.select { |x| x['data-date'.to_sym] == "#{dy}" and x['data-month'.to_sym] == '0' }.first
    date_cell.click
    date_cell.click
    find(:css, '#dt-time-textbox').set "#{time}\n"
  end

  def slickgrid_add_data(start, field_map)
    current_window.resize_to 1000, 1000

    slickgrid_enter_value start, field_map['100'], 'D'
    slickgrid_enter_value start + 1, field_map['100'], 'E'
    slickgrid_enter_value start + 2, field_map['100'], 'F'
    slickgrid_enter_value start + 3, field_map['100'], 'G'

    slickgrid_choose start, field_map['101'], 0
    slickgrid_choose start + 1, field_map['101'], 1
    slickgrid_choose start + 2, field_map['101'], 2
    slickgrid_choose start + 3, field_map['101'], 0

    slickgrid_enter_value start, field_map['102'], '4'
    slickgrid_enter_value start + 1, field_map['102'], '5'
    slickgrid_enter_value start + 2, field_map['102'], '6'
    slickgrid_enter_value start + 3, field_map['102'], '7'

    slickgrid_set_date start + 3, field_map['103'],
      year: 1994,
      day: 4,
      time: '04:04:04'

    slickgrid_set_date start + 2, field_map['103'],
      year: 1993,
      day: 3,
      time: '03:03:03'

    slickgrid_set_date start + 1, field_map['103'],
      year: 1992,
      day: 2,
      time: '02:02:02'

    slickgrid_set_date start, field_map['103'],
      year: 1991,
      day: 1,
      time: '01:01:01'

    slickgrid_enter_value start, field_map['105'], '3, 3'
    slickgrid_enter_value start + 1, field_map['105'], '4, 4'
    slickgrid_enter_value start + 2, field_map['105'], '5, 5'
    slickgrid_enter_value start + 3, field_map['105'], '6, 6'
  end

  test 'slickgrid manual entry' do
    login 'nixon@whitehouse.gov', '12345'

    project = Project.find_by_name 'slickgrid_project'
    visit "/projects/#{project.id}/manualEntry"
    dataset_title = 'ABCDEFGH'

    # enter a valid project title
    find(:css, '#data_set_name').set dataset_title

    # assert that we start with ten blank rows
    page.assert_selector '.slick-row', count: 10

    # build a map of field ids to columns
    fields = all :css, '.slick-header-column'
    field_map = {}
    fields.each.with_index { |x, i| field_map[x[:id][-3..-1]] = i }

    # add three more rows
    button = find :css, '#edit_table_add_2'
    3.times { button.click }

    # assert that we added some rows
    page.assert_selector '.slick-row', count: 13

    # add data to the rows
    slickgrid_add_data 0, field_map

    # save the dataset
    find(:css, '#edit_table_save_1').click

    # assert that we're where we should be
    find '#viscontainer'
    dataset = DataSet.find_by_name dataset_title
    assert page.current_path == "/projects/#{project.id}/data_sets/#{dataset.id}"

    # assert that the data that we saved is there
    assert_similar_arrays compare_data, dataset.data
  end

  test 'slickgrid edit dataset' do
    login 'nixon@whitehouse.gov', '12345'

    dataset = DataSet.find_by_name 'Slickgrid Dataset 1'
    dataset_id = dataset.id
    project_id = dataset.project_id
    visit "/data_sets/#{dataset_id}/edit"

    # assert presence of column headers
    assert page.has_content? 'text_field'
    assert page.has_content? 'restrictions_field'
    assert page.has_content? 'number_field'
    assert page.has_content? 'timestamp_field'
    assert page.has_content? 'latitude_field, longitude_field'

    # assert presence of data
    page.assert_selector '.slick-row', count: 10
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
    page.assert_selector '.slick-row', count: 14

    # add data to those rows
    slickgrid_add_data 3, field_map

    # delete some rows
    find(:css, '.slick-row:nth-child(3) .slick-delete').click
    find(:css, '.slick-row:nth-child(2) .slick-delete').click
    find(:css, '.slick-row:nth-child(1) .slick-delete').click

    # assert correct rows were deleted
    page.assert_selector '.slick-row', count: 11

    # save the dataset
    find(:css, '#edit_table_save_1').click

    # assert that we're where we should be
    find '#viscontainer'
    assert page.current_path == "/projects/#{project_id}/data_sets/#{dataset_id}"

    # assert that the data that we saved is there
    dataset = DataSet.find_by_name 'Slickgrid Dataset 1'
    assert_similar_arrays compare_data, dataset.data
  end
end
