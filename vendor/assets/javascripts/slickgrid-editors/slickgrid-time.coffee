###
	Timestamp Editor for Slickgrid
	Will use the datetime picker to allow the user to enter a date/time combination
###

@TimestampEditor = (args) ->
  form = null
  loadValue = null

  form = ($ args.container).parent().datetimepicker
    onOpen: () ->
      moment()
    onChange: (val) ->
      console.log val
    onClose: (val) ->
      #console.log 'bye!'
      args.commitChanges()
    anchor: ($ args.container).closest '#slickgrid-container > .slick-viewport'
    hPosition: (w, h) ->
      args.position.left - args.gridPosition.left + 2
    vPosition: (w, h) ->
      args.position.top - args.gridPosition.top + 2
  form.open()

  destroy: () ->
    #form.remove()
  focus: () ->
    #form.focus()
  isValueChanged: () =>
    #form.val() != loadValue
  serializeValue: () ->
    #form.val()
  loadValue: (item) ->
    #loadValue = item[args.column.field] || ''
    #form.val loadValue
  applyValue: (item, state) ->
    #item[args.column.field] = state
  validate: () ->
    {valid: true, msg: null}
