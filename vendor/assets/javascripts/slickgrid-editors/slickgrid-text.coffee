###
  Text Editor for Slickgrid
  Because Slickgrid's text editor doesn't support option drop-down boxes.
###

@TextEditor = (args) ->
  form = null
  loadValue = null

  tryCloseForm = =>
    args.grid.getEditorLock().commitCurrentEdit()
    args.grid.resetActiveCell()
    
  $('body').on 'click.slickgrid-text', (e) =>
    if $(e.target).closest('.slick-cell.active').length == 0
      tryCloseForm()

  if args.column.restrictions == ''
    form = $('<input type="text" class="editor-text" />')
    form.appendTo args.container
    form.focus()
  else
    formStr = ''
    for x in args.column.restrictions
      formStr += "<option value=\"#{x}\">#{x}</option>"
    form = $("<select>#{formStr}</select>")
    form.appendTo args.container
    form.focus()

  destroy: ->
    $('body').off 'click.slickgrid-text'
    form.remove()
  focus: ->
    form.focus()
  isValueChanged: ->
    form.val() != loadValue
  serializeValue: ->
    form.val()
  loadValue: (item) ->
    loadValue = item[args.column.field] || ''
    if args.column.restrictions == ''
      form.val loadValue
    else if loadValue in args.column.restrictions
      form.val loadValue
    else
      form.val ''
  applyValue: (item, state) ->
    item[args.column.field] = state
  validate: ->
    # values are entered either through a dropdown, or an anything-goes text field
    # therefore, there cannot be any invalid values entered unless console is used
    {valid: true, msg: null}
