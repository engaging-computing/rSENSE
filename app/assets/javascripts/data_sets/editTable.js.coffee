uploadSettings =
  dataType: 'JSON'
  urlEdit: '#'
  urlEntry: window.location.pathname.substr(0, window.location.pathname.lastIndexOf("/")) + "/jsonDataUpload"
  methodEdit: 'PUT'
  methodEntry: 'POST'
  error: (jqXHR, textStatus, errorThrown) ->
    ($ '#edit_table_add').removeClass 'disabled'
    ($ '#edit_table_save').button 'reset'
    console.log [textStatus, errorThrown]
    alert "An upload error occurred."
  successEdit: (data, textStatus, jqXHR) ->
    window.location = data.redirect
  successEntry: (data, textStatus, jqXHR) ->
    window.location = data['displayURL']

setupTable = (cols, data) ->
  options =
    autoEdit: false
    editable: true
    enableCellNavigation: true
    enableColumnReorder: false
    forceFitColumns: true
  for x, i in data
    data[i]['id'] = i

  view = new Slick.Data.DataView()
  grid = new Slick.Grid '#slickgrid-container', view, cols, options

  view.onRowCountChanged.subscribe (e, args) ->
    grid.updateRowCount()
    grid.render()
  view.onRowsChanged.subscribe (e, args) ->
    grid.invalidateRow args.rows
    grid.render()
  view.setItems data

  [grid, view]

ajaxifyGrid = (view) ->
  buckets = {}
  posHeadRegex = /(\d+)-(\d+)/
  posDataRegex = /(-?\d+\.?\d*), (-?\d+\.?\d*)/

  for i in [0..(view.getLength() - 1)]
    x = view.getItem i
    for j of x
      if j == 'id'
        continue

      idTest = posHeadRegex.exec j
      if idTest != null
        latId = idTest[1]
        lonId = idTest[2]
        if buckets[latId] == undefined then buckets[latId] = []
        if buckets[lonId] == undefined then buckets[lonId] = []

        fieldTest = posDataRegex.exec x[j]
        buckets[latId].push fieldTest[1]
        buckets[lonId].push fieldTest[2]
      else
        if buckets[j] == undefined then buckets[j] = []
        buckets[j].push x[j]

  buckets

IS.onReady 'data_sets/edit', ->
  cols = ($ '#slickgrid-container').data 'cols'
  data = ($ '#slickgrid-container').data 'data'

  rets = setupTable cols, data
  grid = rets[0]
  view = rets[1]

  ($ '#edit_table_add').click ->
    fields = {id: view.getLength()}
    for x in cols
      fields[x.field] = ''
    view.addItem fields

  ($ '#edit_table_save').click ->
    if ($ '#edit_table_save').hasClass 'disabled'
      return
    ($ '#edit_table_add').addClass 'disabled'
    ($ '#edit_table_save').addClass 'disabled'
    ($ '#edit_table_save').text 'Saving...'

    ajaxData =
      data: ajaxifyGrid view

    $.ajax
      url: "#{uploadSettings.urlEdit}"
      type: "#{uploadSettings.methodEdit}"
      dataType: "#{uploadSettings.dataType}"
      data: ajaxData
      error: uploadSettings.error
      success: uploadSettings.successEdit

IS.onReady 'data_sets/manualEntry', ->
  cols = ($ '#slickgrid-container').data 'cols'
  data = ($ '#slickgrid-container').data 'data'

  rets = setupTable cols, data
  grid = rets[0]
  view = rets[1]

  ($ '#edit_table_add').click ->
    fields = {id: view.getLength()}
    for x in cols
      fields[x.field] = ''
    view.addItem fields

  ($ '#edit_table_save').click ->
    if ($ '#edit_table_save').hasClass 'disabled'
      return

    ($ '#edit_table_add').addClass 'disabled'
    ($ '#edit_table_save').addClass 'disabled'
    ($ '#edit_table_save').text 'Saving...'

    ajaxData =
      data: ajaxifyGrid view
      title: ($ '#data_set_name').val()

    console.log ajaxData

    $.ajax
      url: "#{uploadSettings.urlEntry}"
      type: "#{uploadSettings.methodEntry}"
      dataType: "#{uploadSettings.dataType}"
      data: ajaxData
      error: uploadSettings.error
      success: uploadSettings.successEntry
