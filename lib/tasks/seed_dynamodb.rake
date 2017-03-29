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
  	DataSet.all.shuffle.each_slice(12500) do |data_set_arr|
  	  puts "init thr"
  		threadpool << Thread.new(data_set_arr) do |thr_data_sets|
  			datum_arr = []
  			thr_data_sets.each do |data_set|
		  	  data = data_set.data
		  	 	unless data.class == Array
			      data = [data]
			    end
			    dp_id = 0
			    datum_arr << data.map do |datum|
			    	datum.each do |k,v| 
					    if v == ""
					    	datum[k] = nil
					    end
					    if k == ""
					    	datum.delete("")
					    end
					  end
					  dp_id = dp_id + 1
				    { put_request: {
					      item: {
				        'data_set_id' => data_set.id,
				        'datum_id' => dp_id,
				        'datum' => datum,
				      	}
					    }	
					  }
		      end
		    end
		    puts "datum arr length #{datum_arr.length}"
		    datum_arr = datum_arr.flatten
		    puts "datum arr flat length #{datum_arr.length}"
		    datum_arr.shuffle.each_slice(25) do |datums|
		      puts "REQUESTS: #{datums}"
		      dynamodb.batch_write_item({
					  request_items: { 
					    "Datums" => datums,
					  },
					})
					sleep 0.025
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
