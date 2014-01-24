class ViewCount < ActiveRecord::Base
  belongs_to :project
  validates :project_id, uniqueness: true
end
