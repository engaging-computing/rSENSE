class MediaObject < ActiveRecord::Base
  attr_accessible :experiment_id, :media_type, :name, :session_id, :src, :user_id
  belongs_to :owner, class_name: "User", foreign_key: "user_id"
end
