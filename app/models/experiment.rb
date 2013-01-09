class Experiment < ActiveRecord::Base
  attr_accessible :content, :title, :user_id, :filter, :cloned_from, :like_count

  validates_presence_of :title
  validates_presence_of :user_id
  
  has_many :fields
  has_many :experiment_sessions
  has_many :media_objects
  has_many :likes

  belongs_to :owner, class_name: "User", foreign_key: "user_id"
  
  def self.search(search)
    if search
        where('title LIKE ?', "%#{search}%")
    else
        scoped
    end
  end
  
  def self.filter(filters)
   
    if filters
      query = ""
      filters.count.times do |f|
        if(f == 0)
          query += "filter LIKE '#{filters[f]}'"
        else
          query += " OR filter LIKE '#{filters[f]}'"
        end
      end      
      where(query)  

    else
      scoped
    end
  end
  
  def self.is_template
    where(:is_template => true)
  end
  
end

# where filter like filters[0] AND filter like filters[1]