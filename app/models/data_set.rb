class DataSet < ActiveRecord::Base
  
  attr_accessible :content, :project_id, :title, :user_id, :hidden
  
  validates_presence_of :project_id, :user_id
  
  has_many :media_objects
  
  belongs_to :project
  belongs_to :owner, class_name: "User", foreign_key: "user_id"
  
  alias_attribute :name, :title
  
  def self.search(search, include_hidden = false)
    res = if search
        where('title LIKE ?', "%#{search}%")
    else
        scoped
    end
    
    if include_hidden
      res
    else
      res.where({hidden: false})
    end
  end
  
  def self.upload_form(header, datapoints, cur_user, project, name = nil)
    if name == nil
      name = "#{cur_user.name}'s Session"
    end
    
    if !datapoints.nil?     
      data_set = DataSet.create(:user_id => cur_user.id, :project_id => project.id, :title => name)

      mongo_data = []
      
      datapoints.each do |dp|
        row = []
        header.each_with_index do |field, col_index|
          row << { field[1][:id] => dp[1][col_index] }
        end
        mongo_data << row
      end
      
      MongoData.create( data_set_id: data_set.id, data: mongo_data)
    end
    
    return data_set.id
  end
  
  def to_hash(recurse = true)
    h = {
      id: self.id,
      name: self.title,
      hidden: self.hidden,
      url: UrlGenerator.new.data_set_url(self),
      createdAt: self.created_at.strftime("%B %d, %Y")
    }
    
    if recurse
      h.merge! ({
        owner: self.owner.to_hash(false),
        project: self.project.to_hash(false)
      })
    end
    h
  end
end
