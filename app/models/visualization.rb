
require 'nokogiri'
require 'store_file'

class Visualization < ActiveRecord::Base
  
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::SanitizeHelper
  
  attr_accessible :content, :data, :project_id, :globals, :title, :user_id, :hidden, :featured, 
    :featured_at, :tn_src, :tn_file_key, :summary, :thumb_id

  has_many :media_objects
  
  validates_presence_of :title
  validates_presence_of :user_id
  validates_presence_of :project_id
  validates_presence_of :data
  validates_presence_of :globals
  
  validates :title, length: {maximum: 128}
  
  alias_attribute :name, :title
  
  before_save :sanitize_viz
  
  belongs_to :user
  belongs_to :project

  alias_attribute :owner, :user

  def tn_src
    mo = MediaObject.find_by_id(self.thumb_id)
    if mo 
      mo.tn_src
    else
      nil
    end
  end
 
  def sanitize_viz
    self.content = sanitize self.content
    
    # Check to see if there is any valid content left
    html = Nokogiri.HTML(self.content)
    if html.text.blank? and html.at_css("img").nil?
      self.content = nil
    end
    
    self.title = sanitize self.title, tags: %w()
  end
  
  def self.search(search, include_hidden = false)
    res = if search
        where('lower(title) LIKE lower(?)', "%#{search}%")
    else
        all
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
      url: UrlGenerator.new.visualization_url(self),
      path: UrlGenerator.new.visualization_path(self),
      hidden: self.hidden,
      featured: self.featured,
      timeAgoInWords: time_ago_in_words(self.created_at),
      createdAt: self.created_at.strftime("%B %d, %Y"),
      ownerName: self.owner.name,
      ownerUrl: UrlGenerator.new.user_url(self.owner),
      projectName: self.project.name,
      projectUrl: UrlGenerator.new.project_url(self.project)
    }
    
    if self.tn_src != nil
      h.merge!({mediaSrc: self.tn_src})
    end
    
    if recurse
      h.merge! ({
        mediaObjects: self.media_objects.map {|o| o.to_hash false},
        project:      self.project.to_hash(false),
        owner:        self.owner.to_hash(false)
      })
    end
    h
  end
end
