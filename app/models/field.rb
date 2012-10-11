class Field < ActiveRecord::Base
  attr_accessible :experiment_id, :field_type, :name, :unit
  validates_presence_of :experiment_id, :field_type, :name
end
