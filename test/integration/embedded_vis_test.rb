require 'test_helper'
require_relative 'base_integration_test'

class EmbeddedVisTest < IntegrationTest
  self.use_transactional_fixtures = false

  setup do
    @project_id = projects(:dessert).id
    @dataset_id = data_sets(:thanksgiving).id
  end

  test 'embedded vis page' do
    visit "/projects/#{@project_id}/data_sets/#{@dataset_id}?embed=true"
    assert page.has_css?('#vis-ctrls'), 'vis controls should be present'
    assert page.has_css?('#vis-tab-list'), 'vis tabs should be present'
  end

  test 'presentation vis page' do
    visit "/projects/#{@project_id}/data_sets/#{@dataset_id}?presentation=true"
    assert page.has_no_css?('#vis-ctrls'), 'vis controls should not be present'
    assert page.has_no_css?('#vis-tab-list'), 'vis tabs should not be present'
  end
end
