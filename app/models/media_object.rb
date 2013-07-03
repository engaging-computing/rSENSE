class MediaObject < ActiveRecord::Base
  
  attr_accessible :project_id, :media_type, :name, :data_set_id, :src, :user_id, :tutorial_id, :visualization_id, :title, :file_key, :hidden
  
  belongs_to :owner, class_name: "User", foreign_key: "user_id"
  belongs_to :project, class_name: "Project", foreign_key: "project_id" 
  belongs_to :dataSet, class_name: "DataSet", foreign_key: "data_set_id" 
  belongs_to :tutorial, class_name: "Tutorial", foreign_key: "tutorial_id"
  belongs_to :visualization, class_name: "Visualization", foreign_key: "visualization_id"
  
  alias_attribute :title, :name
  
  validates_presence_of :src, :media_type, :file_key
  
  before_destroy :aws_del
  
  def self.search(search, dc)
    if search
        where('name LIKE ?', "%#{search}%")
    else
        scoped
    end
  end
  
  def to_hash(recurse = true)
    h = {
      mediaType: self.media_type,
      name: self.name,
      url: UrlGenerator.new.media_object_url(self),
      createdAt: self.created_at.strftime("%B %d, %Y"),
      src: self.src
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
  
  private
  def aws_del()
    #Set up the link to S3
    s3ConfigFile = YAML.load_file('config/aws_config.yml')
  
    s3 = AWS::S3.new(
      :access_key_id => s3ConfigFile['access_key_id'],
      :secret_access_key => s3ConfigFile['secret_access_key'])
    
    s3.buckets['isenseimgs'].objects[self.file_key].delete
  end
end