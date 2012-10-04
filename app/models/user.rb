class User < ActiveRecord::Base
  attr_accessible :content, :email, :firstname, :group_id, :lastname, :password, :password_confirmation, :username, :validated
  validates_presence_of  :email, unless: :username?
  validates_presence_of  :username, unless: :email?
  validates :email, uniqueness: true, if: :email?
  validates :username, uniqueness: true, if: :username?
  has_secure_password
end


