class Tutorial < ActiveRecord::Base
  attr_accessible :content, :title, :featured_number, :user_id, :hidden

  has_many :media_objects
  
  validates_presence_of :title
  validates_presence_of :user_id
  
  validates_uniqueness_of :featured_number, :allow_nil => true
  has_many :media_objects
  belongs_to :owner, class_name: "User", foreign_key: "user_id"
  
  def self.search(search)
    if search
        where('title LIKE ?', "%#{search}%")
    else
        scoped
    end
  end
  
end
