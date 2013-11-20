class ViewCount < ActiveRecord::Base
  attr_accessible :project_id, :count

  belongs_to :project
end
