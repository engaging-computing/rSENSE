class Tutorial < ActiveRecord::Base
  attr_accessible :content, :title, :featured_number
  
  validates_uniqueness_of :featured_number, :allow_nil => true
  has_many :media_objects
  belongs_to :owner, class_name: "User", foreign_key: "user_id"
  
end
