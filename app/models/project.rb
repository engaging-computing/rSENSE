class Project < ActiveRecord::Base
  
  include ApplicationHelper
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::SanitizeHelper

  attr_accessible :content, :title, :user_id, :filter, :cloned_from, :like_count, :has_fields, :featured, :is_template, :featured_media_id, :hidden, :featured_at
  
  validates_presence_of :title
  validates_presence_of :user_id
  
  validates :title, length: {maximum: 128}
  
  before_save :sanitize_project
  
  has_many :fields
  has_many :data_sets, order: "created_at desc"
  has_many :media_objects
  has_many :likes
  has_many :visualizations

  belongs_to :user
  
  alias_attribute :name, :title
  alias_attribute :owner, :user
  
  def sanitize_project
    self.content = sanitize self.content
    self.title = sanitize self.title, tags: %w()
  end
  
  def self.search(search, include_hidden = false)
    res = if search
        where('(lower(title) LIKE lower(?)) OR (id = ?)', "%#{search}%", search.to_i)
    else
        scoped
    end
    
    if include_hidden
      res
    else
      res.where({hidden: false})
    end
  end
  
  def self.only_templates(value)
    if value == true
      where(:is_template => true)
    else
      scoped
    end
  end
  
  def to_hash(recurse = true)
    h = {
      id: self.id,
      featuredMediaId: self.featured_media_id,
      name: self.name,
      url: UrlGenerator.new.project_url(self),
      path: UrlGenerator.new.project_path(self),
      hidden: self.hidden,
      featured: self.featured,
      likeCount: self.like_count,
      timeAgoInWords: time_ago_in_words(self.created_at),
      createdAt: self.created_at.strftime("%B %d, %Y"),
      ownerName: self.owner.name,
      ownerUrl: UrlGenerator.new.user_url(self.owner),
      dataSetCount: self.data_sets.count,
      fieldCount: self.fields.count,
      fields: self.fields.map {|o| o.to_hash false}
    }
    
    if self.featured_media_id != nil
      h.merge!({mediaSrc: self.media_objects.find(self.featured_media_id).tn_src})
    end
    
    if recurse
      h.merge! ({
        dataSets:     self.data_sets.map     {|o| o.to_hash false},
        mediaObjects: self.media_objects.map {|o| o.to_hash false},
        owner:        self.owner.to_hash(false)
      })
    end
    h
  end
end

# where filter like filters[0] AND filter like filters[1]
