class DataSet < ActiveRecord::Base
  attr_accessible :content, :project_id, :title, :user_id, :file, :hidden
  
  validates_presence_of :project_id, :user_id
  
  belongs_to :project
  belongs_to :owner, class_name: "User", foreign_key: "user_id"
  
  def self.search(search)
    if search
        where('title LIKE ?', "%#{search}%")
    else
        scoped
    end
  end
  
end
