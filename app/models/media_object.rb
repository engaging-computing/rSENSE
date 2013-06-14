class MediaObject < ActiveRecord::Base
  attr_accessible :project_id, :media_type, :name, :session_id, :src, :user_id, :tutorial_id, :visualization_id, :file_key
  
  belongs_to :owner, class_name: "User", foreign_key: "user_id"
  belongs_to :project, class_name: "Project", foreign_key: "project_id" 
  belongs_to :dataSet, class_name: "DataSet", foreign_key: "data_set_id" 
  belongs_to :tutorial, class_name: "Tutorial", foreign_key: "tutorial_id"
  belongs_to :visualization, class_name: "Visualization", foreign_key: "visualization_id"
  
  alias_attribute :title, :name
  
  validates_presence_of :src, :media_type, :file_key
  
  before_destroy :aws_del
  
  def self.search(search)
    if search
        where('name LIKE ?', "%#{search}%")
    else
        scoped
    end
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