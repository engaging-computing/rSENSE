class DataSet < ActiveRecord::Base
  attr_accessible :content, :project_id, :title, :user_id, :file
  
  validates_presence_of :project_id, :user_id
  
  belongs_to :project
  belongs_to :owner, class_name: "User", foreign_key: "user_id"
  
  def self.search(search)
    if search
        where('title LIKE ?', "%#{search}%")
    else
        scoped
    end
  end
  
  def self.upload_form(header, datapoints, cur_user, project)
    if !datapoints.nil?     
      data_set = DataSet.create(:user_id => cur_user.id, :project_id => project.id, :title => "#{cur_user.name}'s Session")

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
  
end
