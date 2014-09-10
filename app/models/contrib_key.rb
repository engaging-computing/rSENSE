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
  validates_uniqueness_of :name, scope: :project, case_sensitive: false
  validates_uniqueness_of :key, scope: :project, case_sensitive: false
  validates :project_id, presence: true
end
