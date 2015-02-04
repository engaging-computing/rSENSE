###
  Number Editor for Slickgrid
  Because Slickgrid only has an 'Integer' editor that prevents the user from
  entering anything that isn't an integer, there needs to be an editor for
  any base-10 number, floating point or otherwise.
###

@NumberEditor = (args) ->
  form = null
  loadValue = null

  form = $('<input type="text" class="editor-text" />')
  form.appendTo args.container
  form.focus()

  destroy: ->
    form.remove()
  focus: ->
    form.focus()
  isValueChanged: ->
    form.val() != loadValue
  serializeValue: ->
    form.val()
  loadValue: (item) ->
    loadValue = item[args.column.field] || ''
    form.val loadValue
  applyValue: (item, state) ->
    item[args.column.field] = state
  validate: ->
    isNumber = /^(?:\+|-)?(?:\d*\.\d+|\d+)$/
    if isNumber.test form.val()
      {valid: true, msg: null}
    else
      {valid: false, msg: 'Please enter a valid number'}
