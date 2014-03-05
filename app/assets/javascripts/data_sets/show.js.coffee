$ ->
  if namespace.controller is "data_sets" and namespace.action is "show"
    metadata = []
    data = []
    sort = {}

    fields = window.fields
    mongo_data = window.mongo_data

    sort[field.id] = [] for field in fields
    
    for field in fields
      metadata.push {
        name: field['name'], label: field['name'], dataType:'string',
        id: field['id'], editable:'true'
      }

    for row in mongo_data
      do (row) ->
        for data_point in row
          do (data_point) ->
            tmp = Object.keys data_point
            key = tmp[0]
            sort[key].push data_point[key]

    keys = Object.keys sort
    data.push {id: key, values: sort[key] } for key in keys
