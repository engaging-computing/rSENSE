class ExperimentSession < ActiveRecord::Base
  attr_accessible :content, :experiment_id, :title, :user_id
  
  validates_presence_of :experiment_id, :user_id
  
  belongs_to :experiment
  belongs_to :owner, class_name: "User", foreign_key: "user_id"
  
end
