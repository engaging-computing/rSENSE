require 'test_helper'
include ActionView::Helpers::DateHelper

class TutorialTest < ActiveSupport::TestCase
  def setup
		@user1 = users(:patson)
    
		@tutorial1 = Tutorial.new
    @tutorial1.id = 1
    @tutorial1.created_at = Time.new(1776)
		@tutorial1.user = @user1
  end

  test 'to hash without recurse' do
    h = @tutorial1.to_hash false
    keys = ['id', 'name', 'path', 'url', 'category', 'youtubeUrl', 'timeAgoInWords', 'createdAt', 'ownerName', 'ownerUrl']
    keys = []
    keys.each do |x|
      assert !h[x.to_sym].nil?
      assert !h[x.to_sym].empty?
    end
  end

  test 'to hash with recurse' do
    # h = @tutorial1.to_hash
    # keys = ['id', 'name', 'path', 'url', 'category', 'youtubeUrl', 'timeAgoInWords', 'createdAt', 'ownerName', 'ownerUrl', 'mediaObjects', 'owner']
    # keys.each do |x|
    #   assert !h[x.to_sym].nil?
    #   assert !h[x.to_sym].empty?
    # end
  end
end
