require 'nokogiri'

class Tutorial < ActiveRecord::Base
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::SanitizeHelper

  validates_presence_of :title
  validates_presence_of :user_id
  validates_presence_of :youtube_url
  validates_presence_of :category

  validates :title, length: { maximum: 128 }

  belongs_to :user

  alias_attribute :name, :title
  alias_attribute :owner, :user

  def self.search(search)
    res = if search
            where('lower(title) LIKE lower(?)', "%#{search}%")
          else
            all
          end
    res
  end

  def to_hash(recurse = true)
    h = {
      id: id,
      name: name,
      path: UrlGenerator.new.tutorial_path(self),
      url: UrlGenerator.new.tutorial_url(self),
      category: category,
      youtubeUrl: youtube_url,
      timeAgoInWords: time_ago_in_words(created_at),
      createdAt: created_at.strftime('%B %d, %Y'),
      ownerName: owner.name,
      ownerUrl: UrlGenerator.new.user_url(owner)
    }

    if recurse
      h.merge!(
        owner: owner.to_hash(false)
      )
    end

    h
  end

end
