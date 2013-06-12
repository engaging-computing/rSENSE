class MediaObject < ActiveRecord::Base
  attr_accessible :project_id, :media_type, :name, :session_id, :src, :user_id, :tutorial_id, :visualization_id, :file_key
  
  belongs_to :owner, class_name: "User", foreign_key: "user_id"
  belongs_to :project, class_name: "Project", foreign_key: "project_id" 
  belongs_to :session, class_name: "DataSet", foreign_key: "data_set_id" 
  belongs_to :tutorial, class_name: "Tutorial", foreign_key: "tutorial_id"
  belongs_to :visualization, class_name: "Visualization", foreign_key: "visualization_id"
  
  alias_attribute :title, :name
  
  validates_presence_of :src, :media_type, :file_key
  
  def self.search(search)
    if search
        where('name LIKE ?', "%#{search}%")
    else
        scoped
    end
  end
end