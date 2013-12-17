class StudentKey < ActiveRecord::Base
  attr_accessible :name, :key, :project_id

  belongs_to :project

  validates :name, length: { minimum: 1 }
  validates :key,  length: { minimum: 1 }
  validates :project_id, presence: true
end
