require 'test_helper'
include ActionView::Helpers::DateHelper

class TutorialTest < ActiveSupport::TestCase
  def setup
    @user1 = users(:patson)
    @sample_media_objects = [media_objects(:one), media_objects(:two)]
    @sample_id = 1
    @sample_name = 'Maisie'
    @sample_category = 'visulaizations'

    @tutorial1 = Tutorial.new
    @tutorial1.id = @sample_id
    @tutorial1.name = @sample_name
    @tutorial1.category = @sample_category
    @tutorial1.youtube_url = @sample_url
    @tutorial1.created_at = Time.new(1776)
    @tutorial1.user = @user1
    @tutorial1.owner = @user1
    @tutorial1.media_objects = @sample_media_objects
  end

  def base_asserts(h, keys)
    assert_equal h[:id], @sample_id
    assert_equal h[:name], @sample_name
    assert_equal h[:category], @sample_category
    assert_equal h[:youtubeUrl], @sample_url
    keys.each do |x|
      assert !h[x.to_sym].nil?
      assert !h[x.to_sym].empty?
    end
  end

  def recurse_asserts(h)
    assert_equal h[:mediaObjects], @sample_media_objects.map { |o| o.to_hash false }
    assert_equal h[:owner], @user1.to_hash(false)
  end

  test 'to hash without recurse without featured media' do
    h = @tutorial1.to_hash false
    keys = ['path', 'url', 'timeAgoInWords', 'createdAt', 'ownerName', 'ownerUrl']
    base_asserts h, keys
    assert_nil h[:featuredMediaId]
  end

  test 'to hash with recurse without featured media' do
    h = @tutorial1.to_hash true
    keys = ['path', 'url', 'timeAgoInWords', 'createdAt', 'ownerName', 'ownerUrl']
    base_asserts h, keys
    recurse_asserts h
    assert_nil h[:featuredMediaId]
  end
end
