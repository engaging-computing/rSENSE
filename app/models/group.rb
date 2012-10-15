class Group < ActiveRecord::Base
  attr_accessible :content, :default_password, :name, :owner_id
  
  has_many :memberships
  has_many :users, :through => :memberships
  
  has_one :owner, :through => :users, :foreign_key => :user_id
  
end
