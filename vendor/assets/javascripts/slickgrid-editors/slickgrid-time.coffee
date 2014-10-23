###
	Timestamp Editor for Slickgrid
	Will use the datetime picker to allow the user to enter a date/time combination
###

@TimestampEditor = (args) ->
  form = null
  loadValue = null

  form = ($ '<div></div>')
  form.datetimepicker()
  form.appendTo args.container
  form.focus()

  destroy: () ->
    form.remove()
  focus: () ->
    form.focus()
  isValueChanged: () =>
    form.val() != loadValue
  serializeValue: () ->
    form.val()
  loadValue: (item) ->
    loadValue = item[args.column.field] || ''
    form.val loadValue
  applyValue: (item, state) ->
    item[args.column.field] = state
  validate: () ->
    {valid: true, msg: null}
