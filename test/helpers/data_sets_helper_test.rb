require 'test_helper'

class DataSetsHelperTest < ActionView::TestCase
  include DataSetsHelper

  def assert_similar_arrays(a, b)
    assert (a - b).length + (b - a).length == 0, "Arrays #{a} and #{b} do not have the same contents"
  end

  test 'slickgrid data formatting - merge lat and lon' do
    project = Project.find_by_name 'slickgrid_project'
    dataset = DataSet.find_by_name 'Slickgrid Dataset 1'
    cols, data = format_slickgrid_merge project.fields, dataset.data

    rescols = [
      {field_type: 1, id: '103', name: 'timestamp_field', restrictions: '""', units: ''},
      {field_type: 2, id: '102', name: 'number_field', restrictions: '""', units: ''},
      {field_type: 3, id: '100', name: 'text_field', restrictions: '""', units: ''},
      {field_type: 3, id: '101', name: 'restrictions_field', restrictions: ['A', 'B', 'C'], units: ''},
      {field_type: 4, id: '104-105', name: 'latitude_field & longitude_field', restrictions: '""', units: ''}
    ]
    assert_similar_arrays cols, rescols

    resdata = [
      {'100' => 'A', '101' => 'A', '102' => '1', '103' => '11', '104-105' => '0, 0'},
      {'100' => 'B', '101' => 'B', '102' => '2', '103' => '22', '104-105' => '1, 1'},
      {'100' => 'C', '101' => 'C', '102' => '3', '103' => '33', '104-105' => '2, 2'}
    ]
    assert_similar_arrays data, resdata
  end

  test 'slickgrid data formatting - skip lat & lon merge' do 
    project = Project.find_by_name 'slickgrid_project_no_latlon'
    dataset = DataSet.find_by_name 'Slickgrid Dataset 2'
    cols, data = format_slickgrid_merge project.fields, dataset.data

    rescols = [{field_type: 3, id: '106', name: 'something', restrictions:'""', units: ''}]
    assert_similar_arrays cols, rescols

    resdata = [{'106' => 'A'}, {'106' => 'B'}, {'106' => 'C'}]
    assert_similar_arrays data, resdata
  end

  test 'slickgrid data population w/ data' do
    project = Project.find_by_name 'slickgrid_project_no_latlon'
    dataset = DataSet.find_by_name 'Slickgrid Dataset 2'
    cols, data = format_slickgrid_merge project.fields, dataset.data
    cols_pop, data_pop = format_slickgrid_populate cols, data

    assert_similar_arrays cols, cols_pop
    assert_similar_arrays data, data_pop
  end

  test 'slickgrid data population w/o data' do
    project = Project.find_by_name 'slickgrid_project_no_latlon'
    dataset = DataSet.find_by_name 'Slickgrid Dataset 3'
    cols, data = format_slickgrid_merge project.fields, dataset.data
    cols_pop, data = format_slickgrid_populate cols, data
    data_pop = [{id: 0, '106' => ''}]

    assert_similar_arrays cols, cols_pop
    assert_similar_arrays data, data_pop
  end
end
