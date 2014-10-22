###
	Location Editor for Slickgrid
	Edits and set latitude/longitude pairs
###

@LocationEditor = (args) ->
	destroy: () ->
		console.log 'destroy'
	focus: () ->
		console.log 'focus'
	isValueChanged: () ->
		console.log 'isValueChanged'
		true
	serializeValue: () ->
		console.log 'serialize'
		''
	loadValue: (item) ->
		console.log 'loadValue'
		console.log "  args: #{item}"
	applyValue: (item, state) ->
		console.log 'applyValue'
		console.log "  args: #{item} {state}"
	validate: () ->
		console.log 'validate'
		true
