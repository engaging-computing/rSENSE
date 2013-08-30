class News < ActiveRecord::Base
  
  attr_accessible :title, :content, :summary, :featured_media_id
  validates :title, length: {maximum: 128}
  validates :summary, length: {maximum: 256}
  has_many :media_objects
  belongs_to :owner, class_name: "User", foreign_key: "user_id"
  
  validates_presence_of :title
  
#   before_save :sanitize_news
#   
#   def sanitize_news
#     
#     self.content = sanitize self.content
#     self.title = sanitize self.title, tags: %w()
#     
#   end
  
  def to_hash()
    h = {
      id: self.id,
      featuredMediaId: self.featured_media_id,
      name: self.title,
      url: UrlGenerator.new.news_url(self),
      hidden: self.hidden,
      timeAgoInWords: time_ago_in_words(self.created_at),
      createdAt: self.created_at.strftime("%B %d, %Y")
    }
    
    if self.featured_media_id != nil
      h.merge!({mediaSrc: self.media_objects.find(self.featured_media_id).tn_src})
    end
    
    h
  end
  
end
