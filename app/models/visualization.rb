class Visualization < ActiveRecord::Base
  attr_accessible :content, :data, :project_id, :globals, :title, :user_id

  validates_presence_of :title
  validates_presence_of :user_id
  validates_presence_of :project_id
  validates_presence_of :data
  validates_presence_of :globals

  belongs_to :owner, class_name: "User", foreign_key: "user_id"
end
