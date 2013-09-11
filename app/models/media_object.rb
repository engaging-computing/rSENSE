class MediaObject < ActiveRecord::Base
  
  include ActionView::Helpers::SanitizeHelper

  
  attr_accessible :project_id, :media_type, :name, :data_set_id, :src, :user_id, :tutorial_id, :visualization_id, :title, :file_key, :hidden, :tn_file_key, :tn_src, :news_id
  
  belongs_to :user
  belongs_to :project
  belongs_to :data_set
  belongs_to :tutorial
  belongs_to :visualization
  belongs_to :news, class_name: "News", foreign_key: "news_id"
  
  alias_attribute :title, :name
  
  validates_presence_of :src, :media_type, :file_key
  
  validates :name, length: {maximum: 128}
  
  before_save :sanitize_media
  before_destroy :aws_del
  
  alias_attribute :owner, :user
  alias_attribute :dataSet, :data_set
  
  def sanitize_media
  
    self.title = sanitize self.title, tags: %w()
    
  end
  
  def self.search(search, dc)
    if search
        where('name LIKE ?', "%#{search}%")
    else
        scoped
    end
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
    end
    h
  end
  
  def add_tn()
    if self.media_type == "image" and self.tn_file_key == "" and self.file_key != nil
      #setup
      s3ConfigFile = YAML.load_file('config/aws_config.yml')
      s3 = AWS::S3.new(
        :access_key_id => s3ConfigFile['access_key_id'],
        :secret_access_key => s3ConfigFile['secret_access_key'])
      
      bucket = s3.buckets['isenseimgs']
      self.tn_file_key = 'tn' + self.file_key
      o = bucket.objects[self.tn_file_key]
      
      #make the thumbnail
      image = MiniMagick::Image.open(self.src)
      image.resize "128"
      
      #finish up
      o.write image.to_blob
      self.tn_src = o.public_url.to_s
      self.save
    end
  end
  
  private
  def aws_del()
    return if Rails.env.test?

    #Set up the link to S3
    s3ConfigFile = YAML.load_file('config/aws_config.yml')
  
    s3 = AWS::S3.new(
      :access_key_id => s3ConfigFile['access_key_id'],
      :secret_access_key => s3ConfigFile['secret_access_key'])
    
    if self.file_key != ""
      s3.buckets['isenseimgs'].objects[self.file_key].delete
    end
    
    if self.tn_file_key != ""
      s3.buckets['isenseimgs'].objects[self.tn_file_key].delete
    end
  end
end
