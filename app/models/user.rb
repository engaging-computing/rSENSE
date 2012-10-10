class User < ActiveRecord::Base
  attr_accessible :content, :email, :firstname, :group_id, :lastname, :password, :password_confirmation, :username, :validated
  
  validates_uniqueness_of :email, case_sensitive: false, if: :email?
  validates_uniqueness_of :username, case_sensitive: false, if: :username?
  
  has_secure_password

  has_many :experiments
  
  validate :has_credentials

  private
  def has_credentials
    if email.blank? and username.blank?
      errors.add :base, "You must have a username and/or email address"
    end
  end
end


