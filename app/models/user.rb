require 'nokogiri'

class User < ActiveRecord::Base
  
  include ActionView::Helpers::SanitizeHelper
  
  attr_accessible :content, :email, :name, :password, :password_confirmation, :username, :validated, :hidden, :bio, :last_login

  validates_uniqueness_of :email, case_sensitive: false
  validates :name, format: {with: /\A[\p{Alpha}\p{Blank}\-\'\.]*\z/, message: "can only contain letters, hyphens, single quotes, periods, and spaces."}
  
  validates :username, length: {maximum: 32}
 
  validates :email, format: {with: /\@.*\./}

  validates_presence_of :name, :email

  has_secure_password

  before_save :sanitize_user
  
  has_many :projects
  has_many :data_sets
  has_many :media_objects
  has_many :visualizations
  has_many :tutorials
  has_many :news
  has_many :likes
  
  def sanitize_user
    self.name = sanitize self.name, tags: %w()
    self.username = sanitize self.username, tags: %w()
    
    self.bio = sanitize self.bio
    
    # Check to see if there is any valid content left
    # Check to see if there is any valid content left
    html = Nokogiri.HTML(self.bio)
    if html.text.blank? and html.at_css("img").nil?
      self.bio = nil
    end
  end
  
  def self.search(search)
    res = if search
        where('lower(name) LIKE lower(?) OR lower(username) LIKE lower(?)', "%#{search}%", "%#{search}%")
    else
        all
    end
  end
  
  def to_hash(recurse = true, show_hidden = false)
    h = {
      id: self.id,
      name: self.name,
      hidden: self.hidden,
      url: UrlGenerator.new.user_url(self),
      path: UrlGenerator.new.user_path(self),
      createdAt: self.created_at.strftime("%B %d, %Y"),
      gravatar: self.email.to_s == "" ? nil : Gravatar.new.url(self,80)
    }
    
    if recurse
      h.merge! ({
        dataSets:       self.data_sets.search(false, show_hidden).map      {|o| o.to_hash false},
        mediaObjects:   self.media_objects.map  {|o| o.to_hash false},
        projects:       self.projects.search(false, show_hidden).map       {|o| o.to_hash false},
        tutorials:      self.tutorials.search(false, show_hidden).map      {|o| o.to_hash false},
        visualizations: self.visualizations.search(false, show_hidden).map {|o| o.to_hash false}
      })
    end
    h
  end

  def reset_validation!
    key = SecureRandom.hex(16)
    self.validation_key = SecureRandom.hex(16)
    return key
  end
end


