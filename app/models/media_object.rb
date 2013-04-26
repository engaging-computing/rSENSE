class MediaObject < ActiveRecord::Base
  attr_accessible :project_id, :media_type, :name, :session_id, :src, :user_id, :tutorial_id
  
  belongs_to :owner, class_name: "User", foreign_key: "user_id"
  belongs_to :project, class_name: "Project", foreign_key: "project_id" 
  belongs_to :session, class_name: "DataSet", foreign_key: "data_set_id" 
  belongs_to :tutorial, class_name: "Tutorial", foreign_key: "tutorial_id"
  
  alias_attribute :title, :name
  
  validates_presence_of :src
  validates_presence_of :media_type
  
  def self.search(search)
    if search
        where('name LIKE ?', "%#{search}%")
    else
        scoped
    end
  end
end