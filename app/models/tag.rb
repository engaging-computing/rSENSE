class Tag < ActiveRecord::Base
  validates :name, uniqueness: true
  validates :name, presence: true

  has_many :taggings, inverse_of: :tag
  has_many :projects, through: :taggings

  def name=(value)
    self[:name] = value.to_s.squish
  end
end
