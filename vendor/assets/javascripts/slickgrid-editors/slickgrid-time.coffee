###
	Timestamp Editor for Slickgrid
	Will use the datetime picker to allow the user to enter a date/time combination
###

@TimestampEditor = (args) ->
  form = null
  currValue = null
  loadValue = null
  pickerOpen = false

  form = $('<div>
    <input type="text" data-provide="datepicker" />
  </div>')
  form.appendTo args.container

  formInput = form.children 'input'
  formInput.focus()

  # formButton = form.children 'i'
  # formButton.click ->
  #   unless pickerOpen
  #     dtPicker.open()

  # dtPicker = formButton.datetimepicker
  #   autoClose: false
  #   keyEventOn: (e) ->
  #     args.grid.onKeyDown.subscribe e
  #   keyEventOff: (e) ->
  #     args.grid.onKeyDown.unsubscribe e
  #   keyPress: (e) ->
  #     e.stopImmediatePropagation()
  #     e.keyCode
  #   onOpen: ->
  #     pickerOpen = true
  #     formInput.focus()
  #     currValue
  #   onChange: (val) ->
  #     currValue = val.format('YYYY/MM/DD HH:mm:ss')
  #     formInput.val currValue
  #   onKeys:
  #     13: -> #enter
  #       dtPicker.close()
  #     27: -> #escape
  #       dtPicker.close()
  #   onClose: (val) ->
  #     pickerOpen = false
  #   hPosition: (w, h) ->
  #     args.position.left + 2
  #   vPosition: (w, h) ->
  #     args.position.bottom + 2

  # getInput: ->
  #   formInput

  destroy: ->
    form.remove()
    if pickerOpen
      dtPicker.close()

  focus: ->
    formInput.focus()

  isValueChanged: ->
    formInput.val() != loadValue

  serializeValue: ->
    formInput.val()

  loadValue: (item) ->
    loadValue = item[args.column.field] || ''
    formInput.val loadValue
    currValue = loadValue

  applyValue: (item, state) ->
    item[args.column.field] = state

  validate: ->
    isDate = moment(formInput.val()).isValid()
    if isDate
      {valid: true, msg: null}
    else
      {valid: false, msg: 'Please enter a valid date'}
