class ContribKey < ActiveRecord::Base
  belongs_to :project

  validates :name, length: { minimum: 1 }
  validates :key,  length: { minimum: 1 }
  validates :project_id, presence: true
end
