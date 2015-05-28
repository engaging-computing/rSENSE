require 'test_helper'

class ApiV1Test < ActionDispatch::IntegrationTest
  setup do
    @project_keys = ['id', 'featuredMediaId', 'name', 'url', 'path', 'hidden', 'featured', 'likeCount', 'content', 'timeAgoInWords', 'createdAt', 'ownerName', 'ownerUrl', 'dataSetCount', 'fieldCount', 'fields']
    @project_keys_extended = @project_keys + ['dataSets', 'mediaObjects', 'owner']
    @field_keys = ['id', 'name', 'type', 'unit', 'restrictions']
    @data_keys = ['id', 'name', 'ownerId', 'ownerName', 'contribKey', 'url', 'path', 'createdAt', 'fieldCount', 'datapointCount', 'displayURL', 'data']
    @data_keys_extended = @data_keys + ['owner', 'project', 'fields']
    @dessert_project = projects(:dessert)
    @thanksgiving_dataset = data_sets(:thanksgiving)
    @media_object_keys = ['id', 'mediaType', 'name', 'url', 'createdAt', 'src', 'tn_src']
    @media_object_keys_extended = @media_object_keys + ['project', 'owner']
    @user_keys = ['gravatar', 'name']

    @test_proj = projects(:media_test)
  end

  private

  def parse(x)
    JSON.parse(x.body)
  end

  def keys_match(x, expected_keys)
    (JSON.parse(x.body).keys.map { |key| expected_keys.include? key }).uniq.length == 1
  end
end
