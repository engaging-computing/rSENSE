class Tutorial < ActiveRecord::Base
  
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::SanitizeHelper

  
  attr_accessible :content, :title, :featured_number, :user_id, :hidden, :featured_media_id

  has_many :media_objects
  
  validates_presence_of :title
  validates_presence_of :user_id
  
  validates_uniqueness_of :featured_number, :allow_nil => true
  validates :title, length: {maximum: 128}
  
  has_many :media_objects
  belongs_to :user
  
  alias_attribute :name, :title
  
  before_save :sanitize_tutorial
  alias_attribute :owner, :user
  
  def sanitize_tutorial
    
    self.content = sanitize self.content
    self.title = sanitize self.title, tags: %w()
    
  end
  
  def self.search(search, include_hidden = false)
    res = if search
        where('title LIKE ?', "%#{search}%")
    else
        scoped
    end
    
    if include_hidden
      res
    else
      res.where({hidden: false})
    end
  end
  
  def to_hash(recurse = true)
    h = {
      id: self.id,
      name: self.name,
      path: UrlGenerator.new.tutorial_path(self),
      url: UrlGenerator.new.tutorial_url(self),
      hidden: self.hidden,
      timeAgoInWords: time_ago_in_words(self.created_at),
      createdAt: self.created_at.strftime("%B %d, %Y"),
      ownerName: self.owner.name,
      ownerUrl: UrlGenerator.new.user_url(self.owner)
    }
    
    if self.featured_media_id != nil
      h.merge!({mediaSrc: self.media_objects.find(self.featured_media_id).tn_src})
    end
    
    if recurse
      h.merge! ({
        mediaObjects: self.media_objects.map {|o| o.to_hash false},
        owner:        self.owner.to_hash(false)
      })
    end
    h
  end
end
