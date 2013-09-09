class Field < ActiveRecord::Base
  attr_accessible :project_id, :field_type, :name, :unit
  validates_presence_of :project_id, :field_type, :name
  validates_uniqueness_of :name, scope: :project_id
  belongs_to :project

  alias_attribute :owner, :project

  default_scope :order => :field_type

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
  
  def self.bulk_update(fields)
    errors = {}
    fields.each do |key, val|
      field = Field.find(key)
      unless field.update_attributes(val)
        errors[key] = field.errors.full_messages
      end
    end
    errors
  end
end
