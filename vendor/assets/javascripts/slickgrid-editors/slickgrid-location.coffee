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

  form.popover
    container: 'body'
    content: ->
      msg
    placement: 'bottom'
    trigger: 'manual'

  tryValidate = ->
    isLocation = /^ *((?:\+|-)?\d+\.?\d*), *((?:\+|-)?\d+\.?\d*) *$/
    result = isLocation.exec form.val()

    ret = unless result?
      {valid: false, msg: 'Please enter a valid latitude and longitude:<br/>e.g. -45.987, 30.12'}
    else if Math.abs(parseInt(result[1])) > 90
      {valid: false, msg: 'Please enter a latitude within -90 to 90 degrees'}
    else if Math.abs(parseInt(result[2])) > 180
      {valid: false, msg: 'Please enter a longitude within -180 to 180 degrees'}
    else
      {valid: true, msg: null}

    msg = ret.msg
    if ret.valid
      form.popover 'hide'
    else
      form.popover 'show'

    ret

  tryCloseForm = ->
    if form.val() != loadValue and tryValidate().valid
      args.grid.getEditorLock().commitCurrentEdit()
      args.grid.resetActiveCell()
    else if form.val() == loadValue
      args.grid.getEditorLock().commitCurrentEdit()
      args.grid.resetActiveCell()
    
  $('body').on 'click.slickgrid-location', (e) =>
    if $(e.target).closest('.slick-cell.active').length == 0
      tryCloseForm()

  destroy: ->
    $('body').off 'click.slickgrid-location'
    form.popover 'destroy'
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
    tryValidate()
