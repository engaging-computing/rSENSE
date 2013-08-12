class DataSet < ActiveRecord::Base
  
  attr_accessible :content, :project_id, :title, :user_id, :hidden
  
  validates_presence_of :project_id, :user_id, :title
  
  has_many :media_objects
  
  belongs_to :project
  belongs_to :owner, class_name: "User", foreign_key: "user_id"
  
  alias_attribute :name, :title
  
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
    data = MongoData.find_by_data_set_id(self.id)
        
    h = {
      id: self.id,
      name: self.title,
      hidden: self.hidden,
      url: UrlGenerator.new.data_set_url(self),
      createdAt: self.created_at.strftime("%B %d, %Y"),
      fieldCount: self.project.fields.length,
      datapointCount: data[:data].length
    }
    
    if recurse
      fields = self.project.fields.map {|f| f.to_hash(false)}
      fieldIndices = Hash.new
      fields.each_with_index do |field, i|
        fieldIndices[field[:id].to_s] = i
      end
      
      newDataHolder = []
      data[:data].each do |inner|
        newDataRow = Hash.new
        inner.each_key do |key|
          newDataRow[fieldIndices[key]] = inner[key]
        end
        newDataHolder.push(newDataRow)
      end
      data[:data] = newDataHolder
    
      h.merge! ({
        owner: self.owner.to_hash(false),
        project: self.project.to_hash(false),
        fields: fields,
        data: data
      })
    end
    h
  end
end
