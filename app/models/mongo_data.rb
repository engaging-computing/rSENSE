class MongoData
  include MongoMapper::Document
  
  key :data_set_id, Integer
  key :data, Array
  
end