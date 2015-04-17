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
    assert page.has_no_css?('#title_row'), 'vis should be fullscreen'
    assert page.has_css?('#controldiv'), 'vis controls should be present'
    assert page.has_no_css?('#saveVisButton'), 'save vis button should not be present'
    assert page.has_css?('#visTabList'), 'vis tabs should be present'
    assert page.has_no_css?('#fullscreen-vis'), 'fullscreen button should not be present'
  end

  test 'presentation vis page' do
    visit "/projects/#{@project_id}/data_sets/#{@dataset_id}?presentation=true"
    assert page.has_no_css?('#title_row'), 'vis should be fullscreen'
    assert page.has_no_css?('#controldiv'), 'vis controls should not be present'
    assert page.has_no_css?('#visTabList'), 'vis tabs should not be present'
  end
end
