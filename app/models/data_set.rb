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
    self.content = sanitize self.content
    
    # Check to see if there is any valid content left
    html = Nokogiri.HTML(self.content)
    if html.text.blank? and html.at_css("img").nil?
      self.content = nil
    end
  end
  
  def self.search(search, include_hidden = false)
    res = if search
        where('title LIKE ?', "%#{search}%").order("created_at DESC")
    else
        all.order("created_at DESC")
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

  def to_csv(tmpdir)
    project = Project.find(self.project_id)
    fields = project.fields
    fname = ("#{self.title.parameterize}.csv")
    tmp_file = File.new("#{tmpdir}/#{fname}", 'w+')

    tmp_file.write(fields.map {|f| f.name}.join(',') + "\n")

    self.data.each do |datapoint|
      tmp_file.write(fields.map {|f| datapoint["#{f.id}"]}.join(',') + "\n")
    end

    tmp_file.close()
    
    fname
  end
  
  def self.get_next_name(project)
    highest = 0
    base = "Dataset #"
    project.data_sets.each do |dset|
      title = dset.title
      if title.include? base
        val = title.split(base)[1].to_i || nil
        next if val == nil
        if val.to_i > highest
          highest = val.to_i
        end
      end  
    end
    "#{base}#{highest+1}"
  end
  
end
