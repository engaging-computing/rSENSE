class Visualization < ActiveRecord::Base
  
  include ActionView::Helpers::DateHelper
  
  attr_accessible :content, :data, :project_id, :globals, :title, :user_id, :hidden, :featured, :featured_at

  has_many :media_objects
  
  validates_presence_of :title
  validates_presence_of :user_id
  validates_presence_of :project_id
  validates_presence_of :data
  validates_presence_of :globals
  
  alias_attribute :name, :title

  belongs_to :owner, class_name: "User", foreign_key: "user_id"
  belongs_to :project
  
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
      url: UrlGenerator.new.visualization_url(self),
      hidden: self.hidden,
      featured: self.featured,
      timeAgoInWords: time_ago_in_words(self.created_at),
      createdAt: self.created_at.strftime("%B %d, %Y"),
      ownerName: self.owner.name,
      ownerUrl: UrlGenerator.new.user_url(self.owner),
      projectName: self.project.name,
      projectUrl: UrlGenerator.new.project_url(self.project)
    }
    
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
