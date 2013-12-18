
require 'store_file'

class MediaObject < ActiveRecord::Base
  include ActionView::Helpers::SanitizeHelper

  attr_accessible :project_id, :media_type, :name, :data_set_id, :src, :user_id, :tutorial_id, 
    :visualization_id, :title, :file_key, :hidden, :tn_file_key, :tn_src, :news_id, :store_key
  
  belongs_to :user
  belongs_to :project
  belongs_to :data_set
  belongs_to :tutorial
  belongs_to :visualization
  belongs_to :news, class_name: "News", foreign_key: "news_id"
  
  alias_attribute :title, :name
  
  validates_presence_of :media_type, :store_key
  validates :name, length: {maximum: 128}
  
  before_save :sanitize_media
  before_save :check_store!

  after_destroy :remove_data!
  
  alias_attribute :owner, :user
  alias_attribute :dataSet, :data_set
  
  def sanitize_media
    self.title = sanitize self.title, tags: %w()
  end

  def check_store!
    if self.store_key.nil?
      self.store_key = store_make_key
    end

    store_make_uudir!(self.store_key)
  end

  def file_name
    uudir = store_uudir(self.store_key)
    "#{uudir}/#{name}"
  end

  def tn_file_name
    uudir = store_uudir(self.store_key)
    "#{uudir}/tn_#{name}"
  end

  def src
    return "" if self.store_key.nil?
    uupath = store_uupath(self.store_key)
    ename  = URI.escape(name)
    "#{uupath}/#{ename}"
  end

  def tn_src
    uupath = store_uupath(self.store_key)
    ename  = URI.escape(name)
    "#{uupath}/tn_#{ename}"
  end

  def to_hash(recurse = true)
    h = {
      id: self.id,
      mediaType: self.media_type,
      name: self.name,
      url: UrlGenerator.new.media_object_url(self),
      createdAt: self.created_at.strftime("%B %d, %Y"),
      src: self.src,
      tn_src: self.tn_src
    }
    
    if recurse
      h.merge!({owner: self.owner.to_hash(false)})
      
      if self.try(:project_id)
        h.merge!({project: self.project.to_hash(false)})
      end
      
      if self.try(:data_set_id)
        h.merge!({dataSet: self.data_set.to_hash(false)})
      end
      
      if self.try(:tutorial_id)
        h.merge!({tutorial: self.tutorial.to_hash(false)})
      end
      
      if self.try(:visualization_id)
        h.merge!({visualization: self.visualization.to_hash(false)})
      end
      
      if self.try(:news_id)
        h.merge!({news: self.news.to_hash(false)})
      end
    end
    h
  end
  
  def add_tn
    if self.media_type == "image"
      #make the thumbnail
      image = MiniMagick::Image.open(self.file_name)
      image.resize "180"
      
      #finish up
      File.open(self.tn_file_name, "wb") do |oo|
        oo.write image.to_blob
      end
      
      File.chmod(0644, self.tn_file_name)
      
      self.save!
    end
  end

  private

  def remove_data!
    begin
      File.delete(self.file_name)
      File.delete(self.tn_file_name)
    rescue Errno::ENOENT
      # whatever
    end
  end
end
