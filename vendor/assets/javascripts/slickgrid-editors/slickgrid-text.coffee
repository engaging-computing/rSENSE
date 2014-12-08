###
  Text Editor for Slickgrid
  Because Slickgrid's text editor doesn't support option drop-down boxes.
###

@TextEditor = (args) ->
  form = null
  loadValue = null

  if args.column.restrictions == ''
    form = ($ '<input type="text" class="editor-text" />')
    form.appendTo args.container
    form.focus()
  else
    formStr = ''
    for x in args.column.restrictions
      formStr += "<option value=\"#{x}\">#{x}</option>"
    form = ($ "<select>#{formStr}</select>")
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
    if args.column.restrictions == ''
      form.val loadValue
    else if loadValue in args.column.restrictions
      form.val loadValue
    else
      form.val ''
  applyValue: (item, state) ->
    item[args.column.field] = state
  validate: () ->
    if args.column.restrictions == ''
      {valid: true, msg: null}
    else if form.val() in args.column.restrictions
      {valid: true, msg: null}
    else
      {valid: false, msg: "Value \"#{form.val()}\" is not a permitted string"}
