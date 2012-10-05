class User < ActiveRecord::Base
  attr_accessible :content, :email, :firstname, :group_id, :lastname, :password, :password_confirmation, :username, :validated
  validates_presence_of  :email, unless: :username?, :case_sensitive => false
  validates_presence_of  :username, unless: :email?, :case_sensitive => false
  validates :email, uniqueness: true, if: :email?
  validates :username, uniqueness: true, if: :username?
  has_secure_password
end


