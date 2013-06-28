class Project < ActiveRecord::Base
  
  include ActionView::Helpers::DateHelper
  
  attr_accessible :content, :title, :user_id, :filter, :cloned_from, :like_count, :has_fields, :featured, :is_template, :featured_media_id, :hidden, :featured_at
  
  validates_presence_of :title
  validates_presence_of :user_id
  
  has_many :fields
  has_many :data_sets
  has_many :media_objects
  has_many :likes

  belongs_to :owner, class_name: "User", foreign_key: "user_id"
  
  alias_attribute :name, :title
  
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
  
  def self.is_template
    where(:is_template => true)
  end
  
  def to_hash(recurse = true)
    h = {
      id: self.id,
      featuredMediaId: self.featured_media_id,
      name: self.name,
      url: UrlGenerator.new.project_url(self),
      hidden: self.hidden,
      featured: self.featured,
      likeCount: self.like_count,
      timeAgoInWords: time_ago_in_words(self.created_at),
      createdAt: self.created_at.strftime("%B %d, %Y"),
      ownerName: self.owner.name,
      ownerUrl: UrlGenerator.new.user_url(self.owner)
    }
    
    if self.featured_media_id != nil
      h.merge!({mediaSrc: self.media_objects.find(self.featured_media_id).src})
    end
    
    if recurse
      h.merge! ({
        fields:       self.fields.map        {|o| o.to_hash false},
        dataSets:     self.data_sets.map     {|o| o.to_hash false},
        mediaObjects: self.media_objects.map {|o| o.to_hash false},
        owner:        self.owner.to_hash(false)
      })
    end
    h
  end
end

# where filter like filters[0] AND filter like filters[1]