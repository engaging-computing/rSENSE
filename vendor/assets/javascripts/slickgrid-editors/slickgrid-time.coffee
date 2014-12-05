###
	Timestamp Editor for Slickgrid
	Will use the datetime picker to allow the user to enter a date/time combination
###

@TimestampEditor = (args) ->
  form = null
  loadValue = null
  currValue = null

  destroy: () ->
    # no need to do anything, datetimepicker is designed well enough to handle this
  focus: () ->
    # see above
  isValueChanged: () =>
    currValue != loadValue
  serializeValue: () ->
    currValue
  loadValue: (item) ->
    time = item[args.column.field]
    currValue = time
    loadValue = time
    ($ args.container).text currValue
    form = ($ args.container).parent().datetimepicker
      onOpen: () ->
        time
      onChange: (val) ->
        currValue = val.format('MM/DD/YYYY HH:mm:ss')
        ($ args.container).text currValue
      onClose: (val) ->
        args.commitChanges()
      anchor: ($ args.container).closest '#slickgrid-container > .slick-viewport'
      hPosition: (w, h) ->
        args.position.left - args.gridPosition.left + 2
      vPosition: (w, h) ->
        args.position.top - args.gridPosition.top + 2
    form.open()
  applyValue: (item, state) ->
    item[args.column.field] = state
  validate: () ->
    {valid: true, msg: null}
