class Like < ActiveRecord::Base
  attr_accessible :experiment_id, :user_id

	#Validate that both of the ids are present
	validates_presence_of :experiment_id, :user_id
	
	#Validate uniqe pairs
	validates_uniqueness_of :experiment_id, :scope => [:user_id]

end
