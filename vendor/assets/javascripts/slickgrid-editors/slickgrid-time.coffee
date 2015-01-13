###
	Timestamp Editor for Slickgrid
	Will use the datetime picker to allow the user to enter a date/time combination
###

@TimestampEditor = (args) ->
  form = null
  loadValue = null
  currValue = null
  canClose = false

  form = $(args.container).parent().datetimepicker
    autoClose: false
    onKeys: {}
    onOpen: ->
      args.grid.focus()
      $('body').on 'click.slickgrid-time', '#dt-picker', ->
        args.grid.focus()
      currValue
    onChange: (val) ->
      currValue = val.format('MM/DD/YYYY HH:mm:ss')
      $(args.container).text currValue
    onClose: (val) ->
      if canClose
        args.grid.getEditorLock().commitCurrentEdit()
        $('body').off 'click.slickgrid-time'
    hPosition: (w, h) ->
      args.position.left + 2
    vPosition: (w, h) ->
      args.position.bottom + 2

  destroy: ->
    # avoiding those stack overflows
    if form?
      temp = form
      form = null
      temp.close()
  focus: ->
    # doesn't do anything
  isValueChanged: =>
    currValue != loadValue
  serializeValue: ->
    currValue
  loadValue: (item) ->
    time = item[args.column.field]
    currValue = time
    loadValue = time
    $(args.container).text currValue
    form.open()
  applyValue: (item, state) ->
    item[args.column.field] = state
  validate: ->
    # it's impossible for an invalid date to be entered via normal means
    # therefore, I don't care to actually validate that
    {valid: true, msg: null}
