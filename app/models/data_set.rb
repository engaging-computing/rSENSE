class DataSet < ActiveRecord::Base
  
  include ActionView::Helpers::SanitizeHelper
  
  attr_accessible :content, :project_id, :title, :user_id, :hidden, :data
  serialize :data, JSON
  
  validates_presence_of :project_id, :user_id, :title
  
  validates_uniqueness_of :title, :scope => [:project_id]
  
  validates :title, length: {maximum: 128}
  
  has_many :media_objects
  
  belongs_to :project
  belongs_to :user
  
  alias_attribute :name, :title
  alias_attribute :owner, :user
  
  before_save :sanitize_data_set
  
  after_create :update_project
  
  def update_project
    proj = Project.find(self.project_id)
    proj.update_attributes(:updated_at => Time.now())
  end
  
  def sanitize_data_set
    self.title = sanitize self.title, tags: %w()
  end
  
  def self.search(search, include_hidden = false)
    res = if search
        where('title LIKE ?', "%#{search}%").order("created_at DESC")
    else
        scoped.order("created_at DESC")
    end
    
    if include_hidden
      res
    else
      res.where({hidden: false})
    end
  end
  
  def to_hash(recurse = true)
    h = {
      id: self.id,
      name: self.title,
      hidden: self.hidden,
      url: UrlGenerator.new.data_set_url(self),
      path: UrlGenerator.new.data_set_path(self),
      createdAt: self.created_at.strftime("%B %d, %Y"),
      fieldCount: self.project.fields.length,
      datapointCount: data.length
    }
    
    if recurse
      fields = self.project.fields.map {|f| f.to_hash(false)}
      fieldIndices = Hash.new
      fields.each_with_index do |field, i|
        fieldIndices[field[:id].to_s] = i
      end
      
      h.merge! ({
        owner: self.owner.to_hash(false),
        project: self.project.to_hash(false),
        fields: fields,
        data: data
      })
    end
    h
  end

  def to_csv()
    project = Project.find(self.project_id)
    fields = project.fields
    fname = ("/tmp/#{project.title}-#{self.title}.csv").squish.downcase.tr(" ","_")
    tmp_file = File.new(fname, 'w+')

    tmp_file.write(fields.map {|f| f.name}.join(',') + "\n")
    self.data.map {|da| tmp_file.write(fields.map {|f| da["#{f.id}"]}.join(',') + "\n")}

    tmp_file.close()
    
    fname
  end
end
