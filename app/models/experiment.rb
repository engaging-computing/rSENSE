class Experiment < ActiveRecord::Base
  attr_accessible :content, :title, :user_id
  validates_presence_of :title
  validates_presence_of :user_id
  has_many :fields
end
