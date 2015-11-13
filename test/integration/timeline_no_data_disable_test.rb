require 'test_helper'
require_relative 'base_integration_test'

class MapNoDataDisableTest < IntegrationTest
  self.use_transactional_fixtures = false

  setup do
    @project_id = projects(:timeline_vis_disable).id
    @dataset_1_id = data_sets(:timeline_vis_disable_dset_with_time).id
    @dataset_2_id = data_sets(:timeline_vis_disable_dset_no_time).id
    @dataset_3_id = data_sets(:timeline_vis_disable_dset_some_time).id
  end

  test 'timeline vis enabled: dset 1, 3 timestamps' do
    visit "/projects/#{@project_id}/data_sets/#{@dataset_1_id}"
    click_on 'Table'
    assert page.has_no_css?('#vis-tab-timeline.strikethrough'), 'timeline vis should be enabled'
  end

  test 'timeline vis disabled: dset 2, 0 timestamps' do
    visit "/projects/#{@project_id}/data_sets/#{@dataset_2_id}"
    assert page.has_css?('#vis-tab-timeline.strikethrough'), 'timeline vis should be disabled'
  end

  test 'timeline vis disabled: dset 3, 2 timestamps' do
    visit "/projects/#{@project_id}/data_sets/#{@dataset_3_id}"
    assert page.has_css?('#vis-tab-timeline.strikethrough'), 'timeline vis should be disabled'
  end

  test 'timeline vis enabled: all dsets' do
    visit "/projects/#{@project_id}/data_sets/#{@dataset_1_id},#{@dataset_2_id},#{@dataset_3_id}"
    assert page.has_no_css?('#vis-tab-timeline.strikethrough'), 'timeline vis should be enabled'
  end
end
