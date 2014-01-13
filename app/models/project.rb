require 'nokogiri'

class Project < ActiveRecord::Base
  
  def self.default_scope
    self.joins("left outer join likes on projects.id = likes.id").select("projects.*, count(likes.id) as like_count").group("projects.id")
  end
  
  include ApplicationHelper
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::SanitizeHelper

  attr_accessible :content, :title, :user_id, :filter, :cloned_from, :has_fields, 
    :featured, :is_template, :featured_media_id, :hidden, :featured_at, :lock, :curated, 
    :curated_at, :updated_at
  
  validates_presence_of :title
  validates_presence_of :user_id
  
  validates :title, length: {maximum: 128}
  
  before_save :sanitize_project
  
  has_many :fields
  has_many :data_sets, -> { order("created_at desc") }
  has_many :media_objects
  has_many :likes
  has_many :visualizations
  has_many :contrib_keys

  has_one :view_count

  belongs_to :user
  
  alias_attribute :name, :title
  alias_attribute :owner, :user
  
  def sanitize_project
    self.content = sanitize self.content
    
    # Check to see if there is any valid content left
    html = Nokogiri.HTML(self.content)
    if html.text.blank? and html.at_css("img").nil?
      self.content = nil
    end
    
    self.title = sanitize self.title, tags: %w()
  end
  
  def self.search(search, include_hidden = false)
    res = if search
        all.where('(lower(projects.title) LIKE lower(?)) OR (projects.id = ?) OR (lower(projects.content) LIKE lower(?))', "%#{search}%", search.to_i, "%#{search}%")
    else
        all
    end
    
    if include_hidden
      res
    else
      res.where({hidden: false})
    end
  end
  
  def self.only_templates(value)
    if value == true
      where(:is_template => true)
    else
      all
    end
  end
  
  def self.only_curated(value)
    if value == true
      where(:curated => true)
    else
      all
    end
  end
  
  def self.only_featured(value)
    if value
      where(:featured => true)
    else
      all
    end
  end
  
  def self.has_data(value)
    if value
      all.joins(:data_sets).distinct
    else
      all
    end
  end

  def has_contrib_key?
    not contrib_keys.empty?
  end

  def add_view!
    vc = view_count
    vc = ViewCount.create({project_id: id}) unless vc
    vc.count = vc.count + 1
    vc.save!
  end

  def views
    return 0 if view_count.nil?
    view_count.count
  end
  
  def to_hash(recurse = true)
    h = {
      id: self.id,
      featuredMediaId: self.featured_media_id,
      name: self.name,
      url: UrlGenerator.new.project_url(self),
      path: UrlGenerator.new.project_path(self),
      hidden: self.hidden,
      featured: self.featured,
      likeCount: self.like_count,
      content: self.content,
      timeAgoInWords: time_ago_in_words(self.created_at),
      createdAt: self.created_at.strftime("%B %d, %Y"),
      ownerName: self.owner.name,
      ownerUrl: UrlGenerator.new.user_url(self.owner),
      dataSetCount: self.data_sets.count,
      fieldCount: self.fields.count,
      fields: self.fields.map {|o| o.to_hash false}
    }
    
    if self.featured_media_id != nil
      h.merge!({mediaSrc: self.media_objects.find(self.featured_media_id).src})
    end
    
    if recurse
      h.merge! ({
        dataSets:     self.data_sets.map     {|o| o.to_hash false},
        mediaObjects: self.media_objects.map {|o| o.to_hash false},
        owner:        self.owner.to_hash(false)
      })
    end
    h
  end
  
  def export_data_sets(datasets)
    require 'fileutils'
    random_hex = SecureRandom.hex
    folder_name = self.title.parameterize
    tmpdir = "/tmp/rsense/#{random_hex}/#{folder_name}"    
    
    begin
      FileUtils.mkdir_p(tmpdir)
      datasets.split(',').each do |d|
        dataset = DataSet.find(d.to_i)
        dataset.to_csv(tmpdir)
      end
      system("(cd /tmp/rsense/#{random_hex} && zip -qr #{folder_name}.zip #{folder_name})")
      zip_file = "/tmp/rsense/#{random_hex}/#{folder_name}.zip"
    rescue
      raise "Failed to export"
    end
    zip_file
  end
  
end

# where filter like filters[0] AND filter like filters[1]
