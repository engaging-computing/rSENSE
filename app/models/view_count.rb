class ViewCount < ActiveRecord::Base
  attr_accessible :project_id, :count

  belongs_to :project

  validates :project_id, uniqueness: true
end
