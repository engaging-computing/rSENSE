require 'aws-sdk'

dynamodb = Aws::DynamoDB::Client.new(
	# endpoint: 'http://localhost:8000',
	region: 'us-east-1'
)

namespace :seed_datums do
  task copy_rdb_to_dynamo: :environment do
  	# start your engines
  	start = Time.now
  	threadpool = []
  	DataSet.all.each_slice(25000) do |data_set_arr|
  		puts "init thr"
  		threadpool << Thread.new do
  			data_set_arr.each do |data_set|
		  	  data = data_set.data
		  	 	unless data.class == Array
			      data = [data]
			    end
			    dp_id = 0
			    data.each_slice(25) do |datums|
			      putrqs = datums.map do |datum|
			      	datum.each do |k,v| 
					      if v == ""
					      	datum[k] = nil
					      end
					      if k == ""
					      	datum.delete("")
					      end
					    end
					    dp_id = dp_id + 1
				      put_request = {
				      	put_request: {
					          item: {
						          'data_set_id' => data_set.id,
						          'datum_id' => dp_id,
						          'datum' => datum,
						        },
					        }
				      }
			      end
			      puts "REQUESTS: #{putrqs}"
			      dynamodb.batch_write_item({
						  request_items: { 
						    "Datums" => putrqs,
						  },
						})	
		      end
		    end
		  end		  
		end
		puts "Threadpool contains #{threadpool.length} threads."
		threadpool.each(&:join)
		finish = Time.now
		puts "done"
		puts finish - start
  end
end
