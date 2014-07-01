require 'nokogiri'

class News < ActiveRecord::Base
  include ActionView::Helpers::DateHelper

  validates :title, length: { maximum: 128 }
  validates :summary, length: { maximum: 256 }
  has_many :media_objects

  belongs_to :user
  alias_attribute :owner, :user

  validates_presence_of :title
  before_save :summernote_media_objects

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

  def summernote_media_objects
    text = Nokogiri.HTML(content)
    text.search('img').each do |picture|
      if picture['src'].include?('data:image')
        data = Base64.decode64(picture['src'].partition('/')[2].split('base64,')[1])
        params = {}
        if picture['src'].partition('/')[2].split('base64,')[0].include? 'png'
          params[:file_type] = '.png'
        else params[:file_type] = '.jpg'
        end
        params[:image_data] = data
        params[:news_id] = id
        summernote_mo = MediaObject.new
        summernote_mo.summernote_image(params)
        summernote_mo.save!
        picture['src'] = summernote_mo.src
      end
    end
    self.content = text.to_html
  end
end
