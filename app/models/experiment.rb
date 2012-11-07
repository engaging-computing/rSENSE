class Experiment < ActiveRecord::Base
  attr_accessible :content, :title, :user_id

  validates_presence_of :title
  validates_presence_of :user_id
  
  has_many :fields
  has_many :experiment_sessions
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
