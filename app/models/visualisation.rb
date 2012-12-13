class Visualisation < ActiveRecord::Base
  attr_accessible :content, :data, :experiment_id, :globals, :title, :user_id
end
