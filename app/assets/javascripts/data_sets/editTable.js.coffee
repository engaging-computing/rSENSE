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
      showError 'Data set titles must be unique to the project'
    else
      showError 'An unknown error has occured'
  successEdit: (data, textStatus, jqXHR) ->
    window.location = data.redirect
  successEntry: (data, textStatus, jqXHR) ->
    window.location = data['displayURL']


#      if e.keyCode == 13 and @grid.getDataLength() - 1 == @grid.getActiveCell().row
#        @addRow true
#      if ((e.keyCode == 37) or (e.keyCode == 9 and e.shiftKey)) and args.cell? and args.cell == 0
#        nextRow = (args.row - 1) % @grid.getDataLength()
#        nextRow += @grid.getDataLength() if nextRow < 0
#        nextCol = @grid.getColumns().length - 2
#        @grid.gotoCell nextRow, nextCol, true
#        e.stopImmediatePropagation()


moveLeft = (args) ->
  args.cell -= 1

moveRight = (args) ->
  args.cell += 1

moveUp = (args) ->
  args.row -= 1

moveDown = (args) ->
  args.row += 1

wrapNew = (args) ->
  if args.grid.getDataLength() == args.row
    args.this.addRow true
  wrapOver args

wrapOver = (args) ->
  grid = args.grid
  numCols = grid.getColumns().length
  numRows = grid.getDataLength()
  dir = args.cell - grid.getActiveCell().cell

  if args.cell < 0
    args.cell += numCols - 1
    args.row -= 1
  else if args.cell >= numCols
    args.cell -= numCols
    args.row += 1

  if args.row < 0
    args.row += numRows
  else if args.row >= numRows
    args.row -= numRows

  grid.gotoCell args.row, args.cell, true

  editor = grid.getCellEditor()
  if dir > 0 and editor? and editor.getInput?
    editor.getInput().caret 0

wrapThru = (args) ->
  editor = args.grid.getCellEditor()
  oldPos = args.grid.getActiveCell()

  if editor? and editor.getInput?
    form = editor.getInput()
    dir = args.cell - oldPos.cell
    if dir < 0 and form.caret() != 0
      form.caret form.caret() - 1
    else if dir > 0 and form.caret() != form.val().length
      form.caret form.caret() + 1
    else
      wrapOver args
  else
    wrapOver args

class Grid
  cols: null
  data: null
  submit: {}

  # slickgrid objects
  view: null
  grid: null

  # objects relevant to popovers
  validationPop: null
  validationPopMsg: null
  deletionPop: null
  deletionPopTimer: null

  # ID counter for rows
  currID: 0

  # queue of save and delete row actions to execute on validation
  actions: []

  constructor: (@cols, @data, @submit) ->
    # this is needed because slickgrid opens after this function completes
    @initialize()
    @subscribeEvents()

  initialize: ->
    # add the delete button to each row
    @cols.push
      id: 'del'
      field: 'del'
      name: ''
      width: 0
      formatter: (row, cell, value, columnDef, dataContext) ->
        '<i class="fa fa-close slick-delete"></i>'

    # slickgrid's grid options
    options =
      autoEdit: true
      editable: true
      enableCellNavigation: true
      enableColumnReorder: false
      enableTextSelectionOnCells: true
      forceFitColumns: true
      rowHeight: 35
      syncColumnCellResize: true

    # associate IDs with each row in the table
    for _, i in @data
      @data[i]['id'] = @currID
      @currID += 1

    # create the required slickgrid objects, give slickgrid the data
    @view = new Slick.Data.DataView()
    @grid = new Slick.Grid '#slickgrid-container', @view, @cols, options
    @view.setItems @data

    setTimeout ->
      $('.slick-cell.l0.r0').first().trigger 'click'
    , 1

  subscribeEvents: ->
    $(window).resize =>
      @resizeWindow()

    $(document).click (e) =>
      if $(e.target).closest('.slick-row, #dt-picker').length == 0
        @grid.getEditorLock().commitCurrentEdit()

    $('.edit_table_add').click =>
      if $('.edit_table_save').hasClass 'disabled'
        return
      @addRow true

    $('.edit_table_cancel').click ->
      projectID = $(document).data 'project'
      window.location = "/projects/#{projectID}"

    $('.edit_table_save').click =>
      @queueSaveGrid()

    @view.onRowsChanged.subscribe (e, args) =>
      @grid.invalidateRow args.rows
      @grid.render()

    @view.onRowCountChanged.subscribe (e, args) =>
      @grid.updateRowCount()
      @grid.render()

    @grid.onActiveCellChanged.subscribe (e, args) =>
      if args.cell? and args.cell == @grid.getColumns().length - 1
        @grid.gotoCell (args.row + 1) % @grid.getDataLength(), 0, true

    @grid.onClick.subscribe (e, args) =>
      cell = @grid.getCellFromEvent e
      if cell.cell == @grid.getColumns().length - 1
        @queueDeleteRow(cell.row)
        if @grid.getDataLength() == 0
          @addRow true

    @grid.onAfterCellEditorDestroy.subscribe =>
      @hidePopover()
      @processActions()

    @grid.onValidationError.subscribe (e, args) =>
      @showPopover $(args.cellNode), args.validationResults.msg
      @actions = []

    @grid.onKeyDown.subscribe (e, args) =>
      args.this = @
      tabMethod = if e.shiftKey then moveLeft else moveRight
      enterMethod = if e.shiftKey then moveUp else moveDown
      switch e.keyCode
        when 9  then @moveCursor e, args, tabMethod,   wrapOver
        when 13 then @moveCursor e, args, enterMethod, wrapNew
        when 37 then @moveCursor e, args, moveLeft,    wrapThru
        when 38 then @moveCursor e, args, moveUp,      wrapOver
        when 39 then @moveCursor e, args, moveRight,   wrapThru
        when 40 then @moveCursor e, args, moveDown,    wrapOver

    $(window).trigger 'resize'

  moveCursor: (e, args, dirMethod, wrapMethod) ->
    e.stopImmediatePropagation()
    dirMethod args
    wrapMethod args

  resizeWindow: ->
    newHeight = $(window).height()-
      $('#row-slickgrid-1').outerHeight() -
      $('#row-slickgrid-2').outerHeight()
    $('#slickgrid-container').height newHeight
    @grid.resizeCanvas()

  getJSON: ->
    buckets = {}
    posHeadRegex = /(\d+)-(\d+)/
    posDataRegex = /^ *((?:\+|-)?\d+\.?\d*), *((?:\+|-)?\d+\.?\d*) *$/

    @view.getItems().forEach (row) ->
      row = Object.keys(row).reduce (curr, prev) ->
        idTest = posHeadRegex.exec prev
        dataTest = posDataRegex.exec row[prev]
        if idTest? and dataTest?
          curr = curr.concat [[idTest[1], dataTest[1]], [idTest[2], dataTest[2]]]
        else if idTest?
          curr = curr.concat [[idTest[1], ''], [idTest[2], '']]
        else unless prev == 'id' or prev == 'del'
          curr.push [prev, row[prev]]
        curr
      , []
      row.forEach (pair) ->
        unless buckets[pair[0]]? then buckets[pair[0]] = []
        buckets[pair[0]].push pair[1]

    buckets

  processActions: ->
    temp = @actions
    @actions = []
    for x in temp
      x()

  addRow: (scroll) ->
    newRow = {id: @currID}
    @currID += 1
    for x in @cols
      newRow[x.field] = ''
    @view.addItem newRow
    if scroll
      @grid.scrollRowIntoView @view.getLength()

  queueDeleteRow: (row) ->
    deleteRow = () =>
      item = @view.getItem row
      @view.deleteItem item.id
      @grid.invalidate()
      if @view.getLength() == 0
        @addRow()
        unless @deletionPop?
          @deletionPop = $('.slick-delete').popover
            container: 'body'
            content: 'There must be at least one row of data'
            placement: 'bottom'
            trigger: 'manual'
          @deletionPop.popover 'show'
          @deletionPopTimer = setTimeout =>
            @deletionPop.popover 'destroy'
            @deletionPop = null
          , 1000
        else
          clearTimeout @deletionPopTimer
          @deletionPopTimer = setTimeout =>
            @deletionPop.popover 'destroy'
            @deletionPop = null
          , 1000

    if @grid.getCellEditor() != null
      @actions.push deleteRow
    else
      deleteRow()

  queueSaveGrid: ->
    saveGrid = =>
      # check if we've already started saving
      if $('.edit_table_save').hasClass 'disabled'
        return

      # get title and grid contents
      @submit['data'] =
        data: @getJSON()
        title: if uploadSettings.pageName == 'entry' then $('#data_set_name').val()

      hasData = Object.keys(@submit['data']['data']).reduce (l, r) =>
        nonEmpty = @submit['data']['data'][r].filter (i) -> i != ''
        nonEmpty.length != 0 or l
      , false

      # validate presence of data
      unless hasData
        showError 'Data sets require data'
        return

      # validate presence of title
      if uploadSettings.pageName == 'entry' and @submit['data'].title == ''
        showError 'Data sets require a title'
        return

      # if we've got this far, we have a valid upload, so turn off the buttons
      $('.edit_table_add, .edit_table_save').addClass 'disabled'
      $('.edit_table_save').text 'Saving...'

      $.ajax @submit

    if @grid.getCellEditor() != null
      @actions.push saveGrid
    else
      saveGrid()

  showPopover: (form, msg) ->
    @validationPopMsg = msg

    if @validationPop? and @validationPop.get(0) != form.get(0)
      @validationPop.popover 'destroy'
      @validationPop = null

    @validationPop = form.popover
      container: 'body'
      content: => @validationPopMsg
      html: true
      placement: 'bottom'
      trigger: 'manual'

    @validationPop.data('bs.popover').setContent()
    @validationPop.popover 'show'

  hidePopover: ->
    if @validationPop?
      @validationPop.popover 'hide'

  length: ->
    @grid.getDataLength()

showError = (error) ->
  $('.mainContent').children('.alert-danger').remove()

  $('.mainContent').prepend "
    <div class='alert alert-danger alert-dismissable'>
      <button type='button' class='close' data-dismiss='alert' aria-hidden='true'>
        &times;
      </button>
      <strong>An error occurred: </strong>
      #{error}
    </div>"

IS.onReady 'data_sets/edit', ->
  uploadSettings.pageName = 'edit'
  cols = $('#slickgrid-container').data 'cols'
  data = $('#slickgrid-container').data 'data'
  grid = new Grid cols, data,
    url: "#{uploadSettings.urlEdit}"
    type: "#{uploadSettings.methodEdit}"
    dataType: "#{uploadSettings.dataType}"
    error: uploadSettings.error
    success: uploadSettings.successEdit

  # ensure a minimum of ten rows per dataset
  newRows = Math.max 1, 10 - grid.length()
  for i in [1 .. newRows]
    grid.addRow false

IS.onReady 'data_sets/manualEntry', ->
  uploadSettings.pageName = 'entry'
  cols = $('#slickgrid-container').data 'cols'
  data = $('#slickgrid-container').data 'data'
  grid = new Grid cols, data,
    url: "#{uploadSettings.urlEntry}"
    type: "#{uploadSettings.methodEntry}"
    dataType: "#{uploadSettings.dataType}"
    error: uploadSettings.error
    success: uploadSettings.successEntry

  # we get one row for free in slickgrid, so just add 9 more
  for i in [1 .. 9]
    grid.addRow false
