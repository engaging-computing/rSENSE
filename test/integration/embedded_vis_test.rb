require 'test_helper'

class EmbeddedVisTest < ActionDispatch::IntegrationTest
  include CapyHelper

  self.use_transactional_fixtures = false

  setup do
    Capybara.current_driver = :webkit
    Capybara.default_wait_time = 15

    @project_id = projects(:dessert).id
    @dataset_id = data_sets(:thanksgiving).id
  end

  teardown do
    finish
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
