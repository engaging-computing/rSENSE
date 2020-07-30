require 'test_helper'
include ActionView::Helpers::DateHelper

class NewsTest < ActiveSupport::TestCase
  def setup
    old_time = Time.new 1776
    @year_diff = time_ago_in_words(old_time)
    @year_text = "January 01, #{old_time.year}"

    @url_regex = %r{.*/news/(\d+)}

    @media_src = media_objects(:one).tn_src

    @news1 = News.new
    @news1.id = 1
    @news1.created_at = old_time
    @news1.updated_at = old_time
    @news1.content = 'something'

    @news2 = News.new
    @news2.id = 2
    @news2.created_at = old_time
    @news2.updated_at = old_time
    @news2.content = 'something else'
    @news2.featured_media_id = media_objects(:one).id
  end

  def base_asserts(obj, h)
    assert_equal obj.id, h[:id]
    if obj.featured_media_id
      assert_equal obj.featured_media_id, h[:featuredMediaId]
    else
      assert_nil h[:featuredMediaId]
    end
    if obj.title
      assert_equal obj.title, h[:name]
    else
      assert_nil h[:name]
    end
    assert_equal obj.hidden, h[:hidden]
    assert_equal h[:timeAgoInWords], @year_diff
    assert_equal h[:createdAt], @year_text

    url_match = @url_regex.match(h[:url])[1]
    assert_equal obj.id.to_s, url_match

    path_match = @url_regex.match(h[:path])[1]
    assert_equal obj.id.to_s, path_match.to_s
  end

  def recurse_asserts(obj, h)
    assert_equal obj.content, h[:content]
  end

  def media_asserts(_obj, h)
    assert_equal @media_src, h[:mediaSrc]
  end

  test 'hash without recurse' do
    h = @news1.to_hash
    h.assert_valid_keys :id, :featuredMediaId, :name, :url, :path, :hidden, :timeAgoInWords, :createdAt
    base_asserts @news1, h
  end

  test 'hash with recurse' do
    h = @news1.to_hash true
    h.assert_valid_keys :id, :featuredMediaId, :name, :url, :path, :hidden, :timeAgoInWords, :createdAt, :content
    base_asserts @news1, h
    recurse_asserts @news1, h
  end

  test 'hash without recurse with featured media' do
    h = @news2.to_hash
    h.assert_valid_keys :id, :featuredMediaId, :name, :url, :path, :hidden, :timeAgoInWords, :createdAt, :mediaSrc
    base_asserts @news2, h
    media_asserts @news2, h
  end

  test 'hash with recurse with featured media' do
    h = @news2.to_hash true
    h.assert_valid_keys :id, :featuredMediaId, :name, :url, :path, :hidden, :timeAgoInWords, :createdAt, :content, :mediaSrc
    base_asserts @news2, h
    recurse_asserts @news2, h
    media_asserts @news2, h
  end
end
