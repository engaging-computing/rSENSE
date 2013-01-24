class ExperimentSession < ActiveRecord::Base
  attr_accessible :content, :experiment_id, :title, :user_id, :file
  
  validates_presence_of :experiment_id, :user_id
  
  belongs_to :experiment
  belongs_to :owner, class_name: "User", foreign_key: "user_id"
  
  def self.search(search)
    if search
        where('title LIKE ?', "%#{search}%")
    else
        scoped
    end
  end
  
end
