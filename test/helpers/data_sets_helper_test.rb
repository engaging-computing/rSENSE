require 'test_helper'

class DataSetsHelperTest < ActionView::TestCase
  include DataSetsHelper

  test 'slickgrid data formatting - merge lat and lon' do
    project = Project.find_by_name 'slickgrid_project'
    dataset = DataSet.find_by_name 'Slickgrid Data set 1'
    cols, data = format_slickgrid_merge project.fields, dataset.data

    rescols = [
      { field_type: 3, id: '100', name: 'text_field', restrictions: '""', units: '' },
      { field_type: 3, id: '101', name: 'restrictions_field', restrictions: ['A', 'B', 'C'], units: '' },
      { field_type: 2, id: '102', name: 'number_field', restrictions: '""', units: '' },
      { field_type: 1, id: '103', name: 'timestamp_field', restrictions: '""', units: '' },
      { field_type: 4, id: '104-105', name: 'latitude_field, longitude_field', restrictions: '""', units: '' }
    ]
    assert_similar_arrays cols, rescols

    resdata = [
      { '100' => 'A', '101' => 'A', '102' => '1', '103' => '11', '104-105' => '0, 0' },
      { '100' => 'B', '101' => 'B', '102' => '2', '103' => '22', '104-105' => '1, 1' },
      { '100' => 'C', '101' => 'C', '102' => '3', '103' => '33', '104-105' => '2, 2' }
    ]
    assert_similar_arrays data, resdata
  end

  test 'slickgrid data formatting - skip lat, lon merge' do
    project = Project.find_by_name 'slickgrid_project_no_latlon'
    dataset = DataSet.find_by_name 'Slickgrid Data set 2'
    cols, data = format_slickgrid_merge project.fields, dataset.data

    rescols = [{ field_type: 3, id: '106', name: 'something', restrictions: '""', units: '' }]
    assert_similar_arrays cols, rescols

    resdata = [{ '106' => 'A' }, { '106' => 'B' }, { '106' => 'C' }]
    assert_similar_arrays data, resdata
  end

  test 'slickgrid data population w/ data' do
    project = Project.find_by_name 'slickgrid_project_no_latlon'
    dataset = DataSet.find_by_name 'Slickgrid Data set 2'
    cols, data = format_slickgrid_merge project.fields, dataset.data
    cols_pop, data_pop = format_slickgrid_populate cols, data

    assert_similar_arrays cols, cols_pop
    assert_similar_arrays data, data_pop
  end

  test 'slickgrid data population w/o data' do
    project = Project.find_by_name 'slickgrid_project_no_latlon'
    dataset = DataSet.find_by_name 'Slickgrid Data set 3'
    cols, data = format_slickgrid_merge project.fields, dataset.data
    cols_pop, data = format_slickgrid_populate cols, data
    data_pop = [{ id: 0, '106' => '' }]

    assert_similar_arrays cols, cols_pop
    assert_similar_arrays data, data_pop
  end

  test 'slickgrid editor association' do
    project = Project.find_by_name 'slickgrid_project'
    dataset = DataSet.find_by_name 'Slickgrid Data set 1'
    cols, data = format_slickgrid_merge project.fields, dataset.data
    cols, data = format_slickgrid_populate cols, data
    cols, data = format_slickgrid_editors cols, data

    rescols = [
      { id: '"slickgrid-100"', name: '"text_field"', field: '"100"', editor: 'TextEditor', restrictions: '""', sortable: 'false' },
      { id: '"slickgrid-101"', name: '"restrictions_field"', field: '"101"', editor: 'TextEditor', restrictions: '["A", "B", "C"]', sortable: 'false' },
      { id: '"slickgrid-102"', name: '"number_field"', field: '"102"', editor: 'NumberEditor', restrictions: '""', sortable: 'false' },
      { id: '"slickgrid-103"', name: '"timestamp_field"', field: '"103"', editor: 'TimestampEditor', restrictions: '""', sortable: 'false' },
      { id: '"slickgrid-104-105"', name: '"latitude_field, longitude_field"', field: '"104-105"', editor: 'LocationEditor', restrictions: '""', sortable: 'false' }
    ]
    assert_similar_arrays cols, rescols

    resdata = '[{"100":"A","101":"A","102":"1","103":"11","104-105":"0, 0"},' \
      '{"100":"B","101":"B","102":"2","103":"22","104-105":"1, 1"},' \
      '{"100":"C","101":"C","102":"3","103":"33","104-105":"2, 2"}]'
    assert data == resdata
  end

  test 'slickgrid editor association oops' do
    project = Project.find_by_name 'slickgrid_oops'
    dataset = DataSet.find_by_name 'Slickgrid Data set Ooops I Messed Up'
    cols, data = format_slickgrid_merge project.fields, dataset.data
    cols, data = format_slickgrid_populate cols, data
    cols, data = format_slickgrid_editors cols, data

    rescols = [
      { id: '"slickgrid-107"', name: '"oops"', field: '"107"', editor: 'Slick.Editors.Text', restrictions: '""', sortable: 'false' }
    ]
    assert_similar_arrays cols, rescols

    resdata = '[{"107":"SOMEBODY ONCE TOLD ME THE WORLD IS GONNA ROLL ME"}]'
    assert data == resdata
  end

  test 'slickgrid format json' do
    project = Project.find_by_name 'slickgrid_project'
    dataset = DataSet.find_by_name 'Slickgrid Data set 1'
    cols, data = format_slickgrid_merge project.fields, dataset.data
    cols, data = format_slickgrid_populate cols, data
    cols, data = format_slickgrid_editors cols, data
    cols, data = format_slickgrid_json cols, data
    cols.gsub!(/(TextEditor|NumberEditor|TimestampEditor|LocationEditor|Slick\.Editors\.Text)/, '"\1"')

    assert cols.is_a? String
    assert data.is_a? String

    begin
      jcols = JSON.parse cols
      jdata = JSON.parse data
    rescue  JSON::ParserError => e
      assert false, e
    end

    jrescols = [
      { 'id' => 'slickgrid-100', 'name' => 'text_field', 'field' => '100', 'editor' => 'TextEditor', 'restrictions' => '', 'sortable' => false },
      { 'id' => 'slickgrid-101', 'name' => 'restrictions_field', 'field' => '101', 'editor' => 'TextEditor', 'restrictions' => ['A', 'B', 'C'], 'sortable' => false },
      { 'id' => 'slickgrid-102', 'name' => 'number_field', 'field' => '102', 'editor' => 'NumberEditor', 'restrictions' => '', 'sortable' => false },
      { 'id' => 'slickgrid-103', 'name' => 'timestamp_field', 'field' => '103', 'editor' => 'TimestampEditor', 'restrictions' => '', 'sortable' => false },
      { 'id' => 'slickgrid-104-105', 'name' => 'latitude_field, longitude_field', 'field' => '104-105', 'editor' => 'LocationEditor', 'restrictions' => '', 'sortable' => false }
    ]
    assert_similar_arrays jcols, jrescols

    jresdata = [
      { '100' => 'A', '101' => 'A', '102' => '1', '103' => '11', '104-105' => '0, 0' },
      { '100' => 'B', '101' => 'B', '102' => '2', '103' => '22', '104-105' => '1, 1' },
      { '100' => 'C', '101' => 'C', '102' => '3', '103' => '33', '104-105' => '2, 2' }
    ]
    assert_similar_arrays jdata, jresdata

  end

  test 'slickgrid full preprocess' do
    project = Project.find_by_name 'slickgrid_project'
    dataset = DataSet.find_by_name 'Slickgrid Data set 1'
    cols, data = format_slickgrid project.fields, dataset.data
    cols.gsub!(/(TextEditor|NumberEditor|TimestampEditor|LocationEditor|Slick\.Editors\.Text)/, '"\1"')

    begin
      jcols = JSON.parse cols
      jdata = JSON.parse data
    rescue  JSON::ParserError => e
      assert false, e
    end

    jrescols = [
      { 'id' => 'slickgrid-100', 'name' => 'text_field<br>', 'field' => '100', 'editor' => 'TextEditor', 'restrictions' => '', 'sortable' => false },
      { 'id' => 'slickgrid-101', 'name' => 'restrictions_field<br>', 'field' => '101', 'editor' => 'TextEditor', 'restrictions' => ['A', 'B', 'C'], 'sortable' => false },
      { 'id' => 'slickgrid-102', 'name' => 'number_field<br>', 'field' => '102', 'editor' => 'NumberEditor', 'restrictions' => '', 'sortable' => false },
      { 'id' => 'slickgrid-103', 'name' => 'timestamp_field<br>', 'field' => '103', 'editor' => 'TimestampEditor', 'restrictions' => '', 'sortable' => false },
      { 'id' => 'slickgrid-104-105', 'name' => 'latitude_field, longitude_field<br>', 'field' => '104-105', 'editor' => 'LocationEditor', 'restrictions' => '', 'sortable' => false }
    ]
    assert_similar_arrays jcols, jrescols

    jresdata = [
      { '100' => 'A', '101' => 'A', '102' => '1', '103' => '11', '104-105' => '0, 0' },
      { '100' => 'B', '101' => 'B', '102' => '2', '103' => '22', '104-105' => '1, 1' },
      { '100' => 'C', '101' => 'C', '102' => '3', '103' => '33', '104-105' => '2, 2' }
    ]
    assert_similar_arrays jdata, jresdata
  end
end
