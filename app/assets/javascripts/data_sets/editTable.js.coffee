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

Grid = (cols, data) ->
  view = null
  grid = null
  currID = 0

  initialize = ->
    # add the delete button to each row
    cols.push
      id: 'del'
      field: 'del'
      name: ''
      width: 0
      formatter: (row, cell, value, columnDef, dataContext) ->
        "<i class='fa fa-close slick-delete'></i>"

    # slickgrid's grid options
    options =
      autoEdit: true
      editable: true
      enableCellNavigation: true
      enableColumnReorder: false
      forceFitColumns: true
      rowHeight: 35
      syncColumnCellResize: true

    # associate IDs with each row in the table
    for _, i in data
      data[i]['id'] = currID
      currID += 1

    # create the required slickgrid objects, give slickgrid the data
    view = new Slick.Data.DataView()
    grid = new Slick.Grid '#slickgrid-container', view, cols, options
    view.setItems data

  subscribe_events = ->
    $(window).resize on_window_resize()
    $('.edit_table_add').click on_add_row_click()
    $('.edit_table_save').click on_save_click()
    view.onRowsChanged.subscribe on_rows_changed()
    view.onRowCountChanged.subscribe on_row_count_changed()

    setTimeout on_start(), 1
    $(window).trigger 'resize'

  on_start = ->
    ->
      $('.slick-cell.l0.r0').first().trigger 'click'

  on_window_resize = ->
    cont = $('#slickgrid-container')
    row1 = $('#row-slickgrid-1').outerHeight()
    row2 = $('#row-slickgrid-2').outerHeight()
    ->
      newHeight = $(window).height() - row1 - row2
      cont.height newHeight
      grid.resizeCanvas()

  on_add_row_click = ->
    ->
      if $('.edit_table_save').hasClass 'disabled'
        return
      add_row()

  on_save_click = ->

  on_cell_click = ->
    (e, args) ->
      cell = grid.getCellFromEvent e
      if cell.cell == grid.getColumns.length - 1
        delete_row()
        if grid.getDataLength() == 0
          add_row()

  on_row_count_changed = ->
    (e, args) ->
      grid.updateRowCount()
      grid.render()

  on_rows_changed = ->
    (e, args) ->
      grid.invalidateRow args.rows
      grid.render()

  get_json = ->
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

  add_row = ->
    newRow = {id: currID}
    currID += 1
    for x in cols
      newRow[x.field] = ''

    view.addItem newRow
    grid.scrollRowIntoView view.getLength()

  delete_row = (row) ->
    item = view.getItem row
    view.deleteItem item.id
    grid.invalidate()


  # subscribing to events
  '''
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
  '''

  # this is needed because slickgrid opens after this function completes
  initialize()
  subscribe_events()

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

IS.onReady 'data_sets/edit', ->
  uploadSettings.pageName = 'edit'
  cols = $('#slickgrid-container').data 'cols'
  data = $('#slickgrid-container').data 'data'
  grid = new Grid cols, data

IS.onReady 'data_sets/manualEntry', ->
  uploadSettings.pageName = 'entry'
  cols = $('#slickgrid-container').data 'cols'
  data = $('#slickgrid-container').data 'data'
  grid = new Grid cols, data
