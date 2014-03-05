class News < ActiveRecord::Base
  include ActionView::Helpers::DateHelper

  validates :title, length: { maximum: 128 }
  validates :summary, length: { maximum: 256 }
  has_many :media_objects

  belongs_to :user
  alias_attribute :owner, :user

  validates_presence_of :title

  def to_hash(recurse = false)
    h = {
      id: id,
      featuredMediaId: featured_media_id,
      name: title,
      url: UrlGenerator.new.news_url(self),
      path: UrlGenerator.new.news_path(self),
      hidden: hidden,
      timeAgoInWords: time_ago_in_words(created_at),
      createdAt: created_at.strftime('%B %d, %Y')
    }

    if recurse
      h.merge!(content: content)
    end

    unless featured_media_id.nil?
      h.merge!(mediaSrc: media_objects.find(featured_media_id).tn_src)
    end

    h
  end
end
