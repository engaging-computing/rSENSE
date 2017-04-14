class Tagging < ActiveRecord::Base
  validates :tag, :project, presence: true

  belongs_to :project, inverse_of: :taggings
  belongs_to :tag, inverse_of: :taggings
end
