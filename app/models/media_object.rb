class MediaObject < ActiveRecord::Base
  attr_accessible :experiment_id, :media_type, :name, :session_id, :src, :user_id
  
  belongs_to :owner, class_name: "User", foreign_key: "user_id"
  belongs_to :experiment, class_name: "Experiment", foreign_key: "experiment_id" 
  belongs_to :session, class_name: "ExperimentSession", foreign_key: "session_id" 
  alias_attribute :title, :name
  
  def self.search(search)
    if search
        where('name LIKE ?', "%#{search}%")
    else
        scoped
    end
  end
end