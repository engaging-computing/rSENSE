class Field < ActiveRecord::Base
  attr_accessible :project_id, :field_type, :name, :unit
  validates_presence_of :project_id, :field_type, :name
  
  belongs_to :owner, class_name: "Project", foreign_key: "project_id"
end
