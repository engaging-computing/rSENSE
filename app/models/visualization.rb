class Visualization < ActiveRecord::Base
  attr_accessible :content, :data, :project_id, :globals, :title, :user_id, :hidden, :featured, :featured_at

  has_many :media_objects
  
  validates_presence_of :title
  validates_presence_of :user_id
  validates_presence_of :project_id
  validates_presence_of :data
  validates_presence_of :globals

  belongs_to :owner, class_name: "User", foreign_key: "user_id"
  belongs_to :project
   def self.search(search)
    if search
        where('title LIKE ?', "%#{search}%").where({hidden: false}).
    else
        scoped.where({hidden: false}).
    end
  end
  
end
