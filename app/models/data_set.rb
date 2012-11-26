class DataSet
  include MongoMapper::Document
  
  key :experiment_session_id, Integer
  key :data, Array
  
end