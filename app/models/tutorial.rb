class Tutorial < ActiveRecord::Base
  
  attr_accessible :content, :title, :featured_number, :user_id, :hidden

  has_many :media_objects
  
  validates_presence_of :title
  validates_presence_of :user_id
  
  validates_uniqueness_of :featured_number, :allow_nil => true
  has_many :media_objects
  belongs_to :owner, class_name: "User", foreign_key: "user_id"
  
  alias_attribute :name, :title
  
  def self.search(search)
    if search
        where('title LIKE ?', "%#{search}%").where({hidden: false})
    else
        scoped.where({hidden: false})
    end
  end
  
  def to_hash(recurse = true)
    h = {
      id: self.id,
      name: self.name,
      url: UrlGenerator.new.tutorial_url(self),
      hidden: self.hidden,
      createdAt: self.created_at.strftime("%B %d, %Y")
    }
    
    if recurse
      h.merge! ({
        mediaObjects: self.media_objects.map {|o| o.to_hash false},
        owner:        self.owner.to_hash(false)
      })
    end
    h
  end
end
