require 'nokogiri'

class User < ActiveRecord::Base
  include ActionView::Helpers::SanitizeHelper

  validates_uniqueness_of :email, case_sensitive: false
  validates :name, length: { minimum: 4, maximum: 32 }, format: {
    with: /\A[\p{Alpha}\p{Blank}\-\'\.]*\z/,
    message: 'can only contain letters, hyphens, single quotes, periods, and spaces.' }

  validates :email, format: { with: /\@.*\./ }, confirmation: true

  validates :password, presence: true, on: :create

  has_secure_password

  before_save :sanitize_user
  before_save :summernote_media_objects
  has_many :projects
  has_many :data_sets
  has_many :media_objects
  has_many :visualizations
  has_many :tutorials
  has_many :news
  has_many :likes

  def sanitize_user
    self.name = sanitize name, tags: %w()

    self.bio = sanitize bio

    # Check to see if there is any valid content left
    html = Nokogiri.HTML(bio)
    if html.text.blank? and html.at_css('img').nil?
      self.bio = nil
    end
  end

  def self.search(search)
    if search
      where('lower(name) LIKE lower(?)', "%#{search}%")
    else
      all
    end
  end

  def to_hash(recurse = true, show_hidden = false)
    h = {
      id: id,
      name: name,
      hidden: hidden,
      url: UrlGenerator.new.user_url(self),
      path: UrlGenerator.new.user_path(self),
      createdAt: created_at.strftime('%B %d, %Y'),
      gravatar: email.to_s == '' ? nil : Gravatar.new.url(self, 80)
    }

    if recurse
      h.merge!(
        dataSets:       data_sets.search(false).map                   { |o| o.to_hash false },
        mediaObjects:   media_objects.map                             { |o| o.to_hash false },
        projects:       projects.search(false, show_hidden).map       { |o| o.to_hash false },
        tutorials:      tutorials.search(false, show_hidden).map      { |o| o.to_hash false },
        visualizations: visualizations.search(false, show_hidden).map { |o| o.to_hash false }
      )
    end
    h
  end

  def reset_validation!
    key = SecureRandom.hex(16)
    self.validation_key = SecureRandom.hex(16)
    key
  end

  def summernote_media_objects
    self.bio = MediaObject.create_media_objects(bio, 'user_id', id)
  end
end


