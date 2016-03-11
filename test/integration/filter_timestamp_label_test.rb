require 'test_helper'
require_relative 'base_integration_test'

class FilterTimestampLabelTest < IntegrationTest
  self.use_transactional_fixtures = false

  setup do
    @project_id = projects(:timeline_vis_disable).id
    @dataset_1_id = data_sets(:timeline_vis_disable_dset_with_time).id
    @dataset_2_id = data_sets(:timeline_vis_disable_dset_no_time).id
    @dataset_3_id = data_sets(:timeline_vis_disable_dset_some_time).id
  end

  test 'filter label for timestamp should show date' do
    visit "/projects/#{@project_id}/data_sets/#{@dataset_1_id},#{@dataset_2_id},#{@dataset_3_id}"
    current_window.resize_to 1000, 1000
    click_on 'Timeline'
    find("#clipping-ctrls").click
    find(".bootstrap-switch-label").click
    click_on "Set Current Filters"
    assert page.has_content?('Dec'), 'filter label for timestamps should be formatted'
  end
end
