class Like < ActiveRecord::Base
	validates_presence_of :project_id, :user_id
	validates_uniqueness_of :project_id, :scope => [:user_id]
end
