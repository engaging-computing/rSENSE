class Like < ActiveRecord::Base
  attr_accessible :project_id, :user_id

	#Validate that both of the ids are present
	validates_presence_of :project_id, :user_id
	
	#Validate uniqe pairs
	validates_uniqueness_of :project_id, :scope => [:user_id]

end
