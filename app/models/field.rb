class Field < ActiveRecord::Base
  attr_accessible :project_id, :field_type, :name, :unit
  validates_presence_of :project_id, :field_type, :name
  
  belongs_to :owner, class_name: "Project", foreign_key: "project_id"
  
  def to_hash(recurse = true)
    h = {
      id: self.id,
      name: self.name,
      type: self.field_type,
      unit: self.unit
    }
    
    if recurse
      h.merge! ({
        project: self.project.to_hash(false)
      })
    end
    h
  end
end
