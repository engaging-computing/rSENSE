class Tutorial < ActiveRecord::Base
  attr_accessible :content, :title, :featured_number
  
  validates_uniqueness_of :featured_number, :allow_nil => true
  
end
