require 'nokogiri'

class Tutorial < ActiveRecord::Base
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::SanitizeHelper

  has_many :media_objects

  validates_presence_of :title
  validates_presence_of :user_id

  validates :title, length: { maximum: 128 }

  has_many :media_objects
  belongs_to :user

  alias_attribute :name, :title

  alias_attribute :owner, :user

  before_save :summernote_media_objects

  def self.search(search, include_hidden = false)
    res = if search
            where('lower(title) LIKE lower(?)', "%#{search}%")
          else
            all
          end

    if include_hidden
      res
    else
      res.where(hidden: false)
    end
  end

  def to_hash(recurse = true)
    h = {
      id: id,
      name: name,
      featured: featured,
      path: UrlGenerator.new.tutorial_path(self),
      url: UrlGenerator.new.tutorial_url(self),
      hidden: hidden,
      timeAgoInWords: time_ago_in_words(created_at),
      createdAt: created_at.strftime('%B %d, %Y'),
      ownerName: owner.name,
      ownerUrl: UrlGenerator.new.user_url(owner)
    }

    unless featured_media_id.nil?
      h.merge!(mediaSrc: media_objects.find(featured_media_id).tn_src)
    end

    if recurse
      h.merge!(
        mediaObjects: media_objects.map { |o| o.to_hash false },
        owner:        owner.to_hash(false)
      )
    end

    h
  end

  def summernote_media_objects
    self.content = MediaObject.create_media_objects(content, 'tutorial_id', id, user_id)
  end
end
