class Visualization < ActiveRecord::Base
  
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::SanitizeHelper
  
  attr_accessible :content, :data, :project_id, :globals, :title, :user_id, :hidden, :featured, 
    :featured_at, :tn_src, :tn_file_key, :summary, :store_key

  has_many :media_objects
  
  validates_presence_of :title
  validates_presence_of :user_id
  validates_presence_of :project_id
  validates_presence_of :data
  validates_presence_of :globals
  
  validates :title, length: {maximum: 128}
  
  alias_attribute :name, :title
  
  before_save :sanitize_viz
  before_save :check_store!
  before_destroy :aws_del
  
  validates :store_key, length: {minimum: 16}

  belongs_to :user
  belongs_to :project

  alias_attribute :owner, :user

  def check_store!
    if self.store_key.nil?
      self.store_key = store_make_key
    end

    store_make_uudir!(self.store_key)
  end
 
  def sanitize_viz
    self.content = sanitize self.content
    self.title = sanitize self.title, tags: %w()
  end
  
  def self.search(search, include_hidden = false)
    res = if search
        where('lower(title) LIKE lower(?)', "%#{search}%")
    else
        scoped
    end
    
    if include_hidden
      res
    else
      res.where({hidden: false})
    end
  end

  def tn_file_name
    uudir = store_uudir(self.store_key)
    "#{uudir}/tn_#{name}"
  end

  def tn_file_path
    uupath = store_uupath(self.store_key)
    "#{uupath}/tn_#{name}"
  end

  def to_hash(recurse = true)
    h = {
      id: self.id,
      name: self.name,
      url: UrlGenerator.new.visualization_url(self),
      path: UrlGenerator.new.visualization_path(self),
      hidden: self.hidden,
      featured: self.featured,
      timeAgoInWords: time_ago_in_words(self.created_at),
      createdAt: self.created_at.strftime("%B %d, %Y"),
      ownerName: self.owner.name,
      ownerUrl: UrlGenerator.new.user_url(self.owner),
      projectName: self.project.name,
      projectUrl: UrlGenerator.new.project_url(self.project)
    }
    
    if self.tn_src != nil
      h.merge!({mediaSrc: self.tn_src})
    end
    
    if recurse
      h.merge! ({
        mediaObjects: self.media_objects.map {|o| o.to_hash false},
        project:      self.project.to_hash(false),
        owner:        self.owner.to_hash(false)
      })
    end
    h
  end
  
  private
  def aws_del()
    #Set up the link to S3
    s3ConfigFile = YAML.load_file('config/aws_config.yml')
  
    s3 = AWS::S3.new(
      :access_key_id => s3ConfigFile['access_key_id'],
      :secret_access_key => s3ConfigFile['secret_access_key'])
    
    if self.tn_file_key != nil
      s3.buckets['isenseimgs'].objects[self.tn_file_key].delete
    end
  end
end
