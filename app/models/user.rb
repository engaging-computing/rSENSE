class User < ActiveRecord::Base
  
  include ActionView::Helpers::SanitizeHelper

  
  attr_accessible :content, :email, :firstname, :lastname, :password, :password_confirmation, :username, :validated, :hidden, :bio

  validates_uniqueness_of :email, case_sensitive: false, if: :email?
  validates :username, uniqueness: true, format: { with: /\A\p{Alnum}*\z/, message: "can only contain letters and numbers." }
  validates :firstname, format: {with: /\A[\p{Alpha}\p{Blank}\-']*\z/, message: "can only contain letters, hyphens, single quotes, and spaces."}
  validates :lastname, format: {with: /\A[\p{Alpha}\p{Blank}\-']*\z/, message: "can only contain letters, hyphens, single quotes, and spaces."}
  
  validates :firstname, length: {maximum: 32}
  validates :lastname, length: {maximum: 32}
  validates :username, length: {maximum: 32}
  
  validates_presence_of :username, :firstname, :lastname

  has_secure_password

  before_create :check_validation
  after_create :check_and_send_validation
  
  before_save :sanitize_user
  
  has_many :projects
  has_many :memberships
  has_many :groups, :through => :memberships
  has_many :data_sets
  has_many :media_objects
  has_many :visualizations
  has_many :tutorials
  has_many :news

  def sanitize_user
  
    self.firstname = sanitize self.firstname, tags: %w()
    self.lastname = sanitize self.lastname, tags: %w()
    self.username = sanitize self.username, tags: %w()
    self.content = sanitize self.content
    self.bio = sanitize self.bio, tags: %w()
    
  end
  
  def to_param
    self.username
  end

  def name
    firstname + " " + lastname[0] + "."
  end

  def self.search(search, include_hidden = false)
    res = if search
        where('firstname LIKE ? OR lastname LIKE ? OR username LIKE ?', "%#{search}%", "%#{search}%", "%#{search}%")
    else
        scoped
    end
    
    if include_hidden
      res
    else
      res.where({hidden: false})
    end
  end
  
  def to_hash(recurse = true, show_hidden = false)
    h = {
      id: self.id,
      name: self.name,
      username: self.username,
      hidden: self.hidden,
      url: UrlGenerator.new.user_url(self),
      path: UrlGenerator.new.user_path(self),
      createdAt: self.created_at.strftime("%B %d, %Y"),
      gravatar: self.email.to_s == "" ? nil : Gravatar.new.url(self,80)
    }
    
    if recurse
      h.merge! ({
        dataSets:       self.data_sets.search(false, show_hidden).map      {|o| o.to_hash false},
        mediaObjects:   self.media_objects.search(false, show_hidden).map  {|o| o.to_hash false},
        projects:       self.projects.search(false, show_hidden).map       {|o| o.to_hash false},
        tutorials:      self.tutorials.search(false, show_hidden).map      {|o| o.to_hash false},
        visualizations: self.visualizations.search(false, show_hidden).map {|o| o.to_hash false},
        news:           self.news.search(false, show_hidden).map           {|o| o.to_hash false}
      })
    end
    h
  end

  private
  def check_validation
    if (not validated) and (not email.blank?)
      self.validation_key = BCrypt::Password::create(email)
    end
  end

  def check_and_send_validation
    if (not validated) and (not validation_key.blank?)
      UserMailer.validation_email(self).deliver
    end
  end
end


