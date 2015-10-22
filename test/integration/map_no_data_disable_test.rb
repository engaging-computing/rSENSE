require 'test_helper'
require_relative 'base_integration_test'

class MapNoDataDisableTest < IntegrationTest
  self.use_transactional_fixtures = false

  setup do
    @project_id = projects(:map_vis_disable).id
    @dataset_1_id = data_sets(:map_vis_disable_dset_with_loc).id
    @dataset_2_id = data_sets(:map_vis_disable_dset_no_loc).id
  end

  test 'map vis enabled: dset 1' do
    visit "/projects/#{@project_id}/data_sets/#{@dataset_1_id}"
    assert page.has_no_css?('#vis-tab-map.strikethrough'), 'map vis should be enabled'
  end

  test 'map vis disabled: dset 2' do
    visit "/projects/#{@project_id}/data_sets/#{@dataset_2_id}"
    assert page.has_css?('#vis-tab-map.strikethrough'), 'map vis should be disabled'
  end

  test 'map vis enabled: both dsets' do
    visit "/projects/#{@project_id}/data_sets/#{@dataset_1_id},#{@dataset_2_id}"
    assert page.has_no_css?('#vis-tab-map.strikethrough'), 'map vis should be enabled'
  end
end
