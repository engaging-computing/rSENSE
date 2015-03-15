###
  Location Editor for Slickgrid
  Edits and set latitude/longitude pairs
###

@LocationEditor = (args) ->
  form = null
  loadValue = null
  msg = null

  form = $('<input type="text" class="editor-text" data-html="true"/>')
  form.appendTo args.container
  form.focus()

  destroy: ->
    form.remove()
  focus: ->
    form.focus()
  isValueChanged: =>
    form.val() != loadValue
  serializeValue: ->
    form.val()
  loadValue: (item) ->
    loadValue = item[args.column.field] || ''
    form.val loadValue
  applyValue: (item, state) ->
    item[args.column.field] = state
  validate: ->
    isLocation = /^ *((?:\+|-)?\d+\.?\d*), *((?:\+|-)?\d+\.?\d*) *$/
    result = isLocation.exec form.val()
    unless result?
      {valid: false, msg: 'Please enter a valid latitude and longitude:<br/>e.g. -45.987, 30.12'}
    else if Math.abs(parseInt(result[1])) > 90
      {valid: false, msg: 'Please enter a latitude within -90 to 90 degrees'}
    else if Math.abs(parseInt(result[2])) > 180
      {valid: false, msg: 'Please enter a longitude within -180 to 180 degrees'}
    else
      {valid: true, msg: null}
