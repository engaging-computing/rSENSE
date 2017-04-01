require 'aws-sdk'

dynamodb = Aws::DynamoDB::Client.new(
	# endpoint: 'http://localhost:8000',
	region: 'us-east-1'
)

tables = dynamodb.list_tables

unless tables.table_names.include?("Data")
	dynamodb.create_table({
	  table_name: 'Data',
	  attribute_definitions: [
	    {attribute_name: 'data_set_id', attribute_type: 'N'},
	    {attribute_name: 'datum_id', attribute_type: 'N'}
	  ],
	  key_schema: [
	    {attribute_name: 'data_set_id', key_type: 'HASH'},
	    {attribute_name: 'datum_id', key_type: 'RANGE'}
	  ],
	  provisioned_throughput: {
	    read_capacity_units: 1,
	    write_capacity_units: 500
	  }
	})
end