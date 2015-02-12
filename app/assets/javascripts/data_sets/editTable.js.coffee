uploadSettings =
  dataType: 'JSON'
  urlEdit: '#'
  urlEntry: window.location.pathname.replace('manualEntry', 'jsonDataUpload')
  methodEdit: 'PUT'
  methodEntry: 'POST'
  error: (jqXHR, textStatus, errorThrown) ->
    $('.edit_table_add, .edit_table_save').removeClass 'disabled'
    $('.edit_table_save').text 'Save'

    if uploadSettings.pageName == 'entry'
      showError 'Dataset titles must be unique to the project'
    else
      showError 'An unknown error has occured'
  successEdit: (data, textStatus, jqXHR) ->
    window.location = data.redirect
  successEntry: (data, textStatus, jqXHR) ->
    window.location = data['displayURL']

setupTable = (cols, data) ->
  cols.push
    id: 'del'
    field: 'del'
    name: ''
    width: 0
    formatter: (row, cell, value, columnDef, dataContext) ->
      "<i class='fa fa-close slick-delete'></i>"

  options =
    autoEdit: true
    editable: true
    enableCellNavigation: true
    enableColumnReorder: false
    forceFitColumns: true
    rowHeight: 35
    syncColumnCellResize: true

  for x, i in data
    data[i]['id'] = i

  view = new Slick.Data.DataView()
  grid = new Slick.Grid '#slickgrid-container', view, cols, options
  currId = data.length

  view.setItems data

  grid.onClick.subscribe (e, args) ->
    cell = grid.getCellFromEvent e
    if cell.cell == grid.getColumns().length - 1
      grid.getEditorLock().commitCurrentEdit()
      grid.resetActiveCell()
      item = view.getItem cell.row
      view.deleteItem item.id
      grid.invalidate()

      if grid.getDataLength() == 0
        fields = {id: currId}
        currId += 1
        for x in cols
          fields[x.field] = ''
        view.addItem fields

  view.onRowCountChanged.subscribe (e, args) ->
    grid.updateRowCount()
    grid.render()

  view.onRowsChanged.subscribe (e, args) ->
    grid.invalidateRow args.rows
    grid.render()

  $('.edit_table_add').click ->
    if $('.edit_table_save').hasClass 'disabled'
      return

    grid.getEditorLock().commitCurrentEdit()
    grid.resetActiveCell()

    fields = {id: currId}
    currId += 1
    for x in cols
      fields[x.field] = ''
    view.addItem fields
    grid.scrollRowIntoView view.getLength()

  $('.edit_table_save').click ->

    # commit the current edit regardless of whether or not we can actually upload
    grid.getEditorLock().commitCurrentEdit()
    grid.resetActiveCell()

    # check if we've already started saving
    if $('.edit_table_save').hasClass 'disabled'
      return

    # get title and grid contents
    title = if uploadSettings.pageName == 'entry' then $('#data_set_name').val() else ''
    formattedData = ajaxifyGrid view

    # validate presence of data
    for i of formattedData
      for j in formattedData[i]
        unless j == ''
          hasData = true
          break
      if hasData
        break
          
    unless hasData
      showError 'Datasets require data'
      return

    # validate presence of title
    if uploadSettings.pageName == 'entry' and title == ''
      showError 'Datasets require a title'
      return

    # if we've got this far, we have a valid upload, so turn off the buttons
    $('.edit_table_add, .edit_table_save').addClass 'disabled'
    $('.edit_table_save').text 'Saving...'

    if uploadSettings.pageName == 'edit'
      $.ajax
        url: "#{uploadSettings["urlEdit"]}"
        type: "#{uploadSettings["methodEdit"]}"
        dataType: "#{uploadSettings.dataType}"
        data:
          data: formattedData
        error: uploadSettings.error
        success: uploadSettings.successEdit
    else if uploadSettings.pageName == 'entry'
      $.ajax
        url: "#{uploadSettings["urlEntry"]}"
        type: "#{uploadSettings["methodEntry"]}"
        dataType: "#{uploadSettings.dataType}"
        data:
          data: formattedData
          title: title
        error: uploadSettings.error
        success: uploadSettings.successEntry

  # this is needed because slickgrid opens after this function completes
  setTimeout ->
    $('.slick-cell.l0.r0').trigger 'click'
  , 1

  [grid, view]

setupResizer = (grid) ->
  cont = $('#slickgrid-container')
  row1 = $('#row-slickgrid-1')
  row2 = $('#row-slickgrid-2')

  getHeight = ->
    $(window).height() - row1.outerHeight() - row2.outerHeight()

  $(window).resize ->
    a = getHeight()
    cont.height a
    grid.resizeCanvas()

  $(window).trigger 'resize'

showError = (error) ->
  $('.mainContent').children('.alert-danger').remove()

  $('.mainContent').prepend """
    <div class='alert alert-danger alert-dismissable'>
      <button type='button' class='close' data-dismiss='alert' aria-hidden='true'>
        &times;
      </button>
      <strong>An error occurred: </strong>
      #{error}
    </div>"""

ajaxifyGrid = (view) ->
  buckets = {}
  posHeadRegex = /(\d+)-(\d+)/
  posDataRegex = /^ *((?:\+|-)?\d+\.?\d*), *((?:\+|-)?\d+\.?\d*) *$/

  for i in [0..(view.getLength() - 1)]
    x = view.getItem i
    for j of x
      if j == 'id' or j == 'del'
        continue

      unless x[j]?
        x[j] = ''

      idTest = posHeadRegex.exec j
      if idTest?
        latId = idTest[1]
        lonId = idTest[2]
        unless buckets[latId]? then buckets[latId] = []
        unless buckets[lonId]? then buckets[lonId] = []

        fieldTest = posDataRegex.exec x[j]
        if fieldTest?
          buckets[latId].push fieldTest[1]
          buckets[lonId].push fieldTest[2]
        else
          buckets[latId].push ''
          buckets[lonId].push ''
      else
        unless buckets[j]? then buckets[j] = []
        buckets[j].push x[j]

  buckets

IS.onReady 'data_sets/edit', ->
  uploadSettings.pageName = 'edit'

  cols = $('#slickgrid-container').data 'cols'
  data = $('#slickgrid-container').data 'data'

  rets = setupTable cols, data
  grid = rets[0]
  view = rets[1]

  setupResizer grid

IS.onReady 'data_sets/manualEntry', ->
  uploadSettings.pageName = 'entry'

  cols = $('#slickgrid-container').data 'cols'
  data = $('#slickgrid-container').data 'data'

  rets = setupTable cols, data
  grid = rets[0]
  view = rets[1]

  setupResizer grid
