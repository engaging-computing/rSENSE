class Project < ActiveRecord::Base
  attr_accessible :content, :title, :user_id, :filter, :cloned_from, :like_count, :has_fields, :featured, :is_template, :featured_media_id, :hidden, :featured_at
  
  validates_presence_of :title
  validates_presence_of :user_id
  
  has_many :fields
  has_many :data_sets
  has_many :media_objects
  has_many :likes

  belongs_to :owner, class_name: "User", foreign_key: "user_id"
  
  def self.search(search)
    if search
        where('title LIKE ?', "%#{search}%").where({hidden: false})
    else
        scoped.where({hidden: false})
    end
  end
  
  def self.is_template
    where(:is_template => true)
  end
  
end

# where filter like filters[0] AND filter like filters[1]