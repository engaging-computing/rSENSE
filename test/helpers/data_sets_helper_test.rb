require 'test_helper'

class DataSetsHelperTest < ActionView::TestCase
  include DataSetsHelper

  test 'slickgrid data formatting - merge latitude and longitude columns' do
    proj = Project.find_by_name 'slickgrid_project'
    cols, data = format_slickgrid_merge proj.fields, proj.data_sets[0].data

    rescols = [
      {field_type: 1, id: '103', name: 'timestamp_field', restrictions: '""', units: ''},
      {field_type: 2, id: '102', name: 'number_field', restrictions: '""', units: ''},
      {field_type: 3, id: '100', name: 'text_field', restrictions: '""', units: ''},
      {field_type: 3, id: '101', name: 'restrictions_field', restrictions: ['A', 'B', 'C'], units: ''},
      {field_type: 4, id: '104-105', name: 'latitude_field & longitude_field', restrictions: '""', units: ''}
    ]
    assert cols - rescols == []

    resdata = [
      {'100' => 'A', '101' => 'A', '102' => '1', '103' => '11', '104-105' => '0, 0'},
      {'100' => 'B', '101' => 'B', '102' => '2', '103' => '22', '104-105' => '1, 1'},
      {'100' => 'C', '101' => 'C', '102' => '3', '103' => '33', '104-105' => '2, 2'}
    ]
    assert data - resdata == []
  end

  test 'slickgrid data formatting - skip latitude & longitude merging' do 
    proj = Project.find_by_name 'slickgrid_project_no_latlon'
    cols, data = format_slickgrid_merge proj.fields, proj.data_sets[0].data

    rescols = [{field_type: 3, id: '106', name: 'something', restrictions:'""', units: ''}]
    assert cols - rescols == []

    resdata = [{'106' => 'A'}, {'106' => 'B'}, {'106' => 'C'}]
    assert data - resdata == []
  end
end
