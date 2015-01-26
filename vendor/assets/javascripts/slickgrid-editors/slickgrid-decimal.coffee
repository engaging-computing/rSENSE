###
  Number Editor for Slickgrid
  Because Slickgrid only has an 'Integer' editor that prevents the user from
  entering anything that isn't an integer, there needs to be an editor for
  any base-10 number, floating point or otherwise.
###

@NumberEditor = (args) ->
  form = null
  loadValue = null

  tryValidate = ->
    isNumber = /^(?:\+|-)?(?:\d*\.\d+|\d+)$/
    if isNumber.test form.val()
      form.popover 'hide'
      {valid: true, msg: null}
    else
      form.popover 'show'
      {valid: false, msg: 'Please enter a valid number'}

  tryCloseForm = ->
    if form.val() != loadValue and tryValidate().valid
      args.grid.getEditorLock().commitCurrentEdit()
      args.grid.resetActiveCell()
    else if form.val() == loadValue
      args.grid.getEditorLock().commitCurrentEdit()
      args.grid.resetActiveCell()
    
  $('body').on 'click.slickgrid-number', (e) =>
    if $(e.target).closest('.slick-cell.active').length == 0
      tryCloseForm()

  form = $('<input type="text" class="editor-text" />')
  form.appendTo args.container
  form.focus()

  form.popover
    container: 'body'
    content: 'Please enter a valid number.'
    placement: 'bottom'
    trigger: 'manual'

  destroy: ->
    $('body').off 'click.slickgrid-number'
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
  validate: tryValidate
