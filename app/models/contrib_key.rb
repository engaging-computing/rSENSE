class ContribKey < ActiveRecord::Base
  belongs_to :project

  validates :name, length: {
    minimum: 1,
    too_short:  ' is too short (Minimum is one character)',
    maximum: 40
  }
  validates :key,  length: {
    minimum: 1,
    too_short:  'is too short (Minimum is one character)',
    maximum: 40
    }

  validates :project_id, presence: true
end
