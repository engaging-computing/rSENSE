class User < ActiveRecord::Base
  attr_accessible :content, :email, :firstname, :lastname, :password, :password_confirmation, :username, :validated
  
  validates_uniqueness_of :email, case_sensitive: false, if: :email?
  validates_uniqueness_of :username, case_sensitive: false
  validates_presence_of :username
  
  has_secure_password

  before_create :check_validation
  after_create :check_and_send_validation

  has_many :experiments
  has_many :memberships
  has_many :groups, :through => :memberships
  has_many :experiment_sessions
  
  
  private
  def check_validation
    if (not validated) and (not email.blank?)
      self.validation_key = BCrypt::Password::create(email)
    end
  end
  
  def check_and_send_validation
    if (not validated) and (not validation_key.blank?)
      UserMailer.validation_email(self)
    end
  end
end


