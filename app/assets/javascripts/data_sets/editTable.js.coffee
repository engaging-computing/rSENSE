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
    console.log data
    console.log textStatus
    console.log jqXHR
    window.location = data.redirect
  successEntry: (data, textStatus, jqXHR) ->
    window.location = data['displayURL']

Grid = (cols, data, submit) ->
  view = null
  grid = null
  popover = null
  popoverMsg = 'hi'
  currID = 0
  actions = []

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
    $(window).resize resize_window

    $(document).click (e) ->
      if $(e.target).closest('.slick-row').length == 0
        grid.getEditorLock().commitCurrentEdit()

    $('.edit_table_add').click ->
      if $('.edit_table_save').hasClass 'disabled'
        return
      add_row()

    $('.edit_table_save').click queue_save_grid

    view.onRowsChanged.subscribe (e, args) ->
      grid.invalidateRow args.rows
      grid.render()

    view.onRowCountChanged.subscribe (e, args) ->
      grid.updateRowCount()
      grid.render()

    grid.onClick.subscribe (e, args) ->
      cell = grid.getCellFromEvent e
      if cell.cell == grid.getColumns().length - 1
        queue_delete_row(cell.row)
        if grid.getDataLength() == 0
          add_row()

    grid.onAfterCellEditorDestroy.subscribe ->
      hide_popover()
      process_actions()

    grid.onValidationError.subscribe (e, args) ->
      show_popover $(args.cellNode), args.validationResults.msg
      actions = []

    $(window).trigger 'resize'

    setTimeout ->
      $('.slick-cell.l0.r0').first().trigger 'click'
    , 1

  resize_window = ->
    cont = $('#slickgrid-container')
    row1 = $('#row-slickgrid-1').outerHeight()
    row2 = $('#row-slickgrid-2').outerHeight()
    newHeight = $(window).height() - row1 - row2
    cont.height newHeight
    grid.resizeCanvas()

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

  process_actions = ->
    temp = actions
    actions = []
    for x in temp
      x()    

  add_row = ->
    newRow = {id: currID}
    currID += 1
    for x in cols
      newRow[x.field] = ''
    view.addItem newRow
    grid.scrollRowIntoView view.getLength()

  queue_delete_row = (row) ->
    delete_row = () ->
      item = view.getItem row
      view.deleteItem item.id
      grid.invalidate()
      if view.getLength() == 0
        add_row()

    if grid.getCellEditor() != null
      actions.push delete_row
    else
      delete_row()

  queue_save_grid = ->
    save_grid = ->
      # check if we've already started saving
      if $('.edit_table_save').hasClass 'disabled'
        return

      # get title and grid contents
      submit['data'] =
        data: get_json()
        title: if uploadSettings.pageName == 'entry' then $('#data_set_name').val()

      hasData = Object.keys(submit['data']['data']).reduce (l, r) ->
        nonEmpty = submit['data']['data'][r].filter (i) -> i != ''
        nonEmpty.length != 0 or l
      , false

      # validate presence of data
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

      $.ajax submit

    if grid.getCellEditor() != null
      actions.push save_grid
    else
      save_grid()

  show_popover = (form, msg) =>
    popoverMsg = msg
    unless popover?
      popover = form.popover
        container: 'body'
        content: -> popoverMsg
        html: true
        placement: 'bottom'
        trigger: 'manual'
    popover.data('bs.popover').setContent()
    popover.popover 'show'

  hide_popover = ->
    if popover?
      popover.popover 'hide'

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

IS.onReady 'data_sets/edit', ->
  uploadSettings.pageName = 'edit'
  cols = $('#slickgrid-container').data 'cols'
  data = $('#slickgrid-container').data 'data'
  grid = new Grid cols, data,
    url: "#{uploadSettings["urlEdit"]}"
    type: "#{uploadSettings["methodEdit"]}"
    dataType: "#{uploadSettings.dataType}"
    error: uploadSettings.error
    success: uploadSettings.successEdit

IS.onReady 'data_sets/manualEntry', ->
  uploadSettings.pageName = 'entry'
  cols = $('#slickgrid-container').data 'cols'
  data = $('#slickgrid-container').data 'data'
  grid = new Grid cols, data,
    url: "#{uploadSettings["urlEntry"]}"
    type: "#{uploadSettings["methodEntry"]}"
    dataType: "#{uploadSettings.dataType}"
    error: uploadSettings.error
    success: uploadSettings.successEntry
