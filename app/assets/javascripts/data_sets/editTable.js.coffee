setupTable = (cols, data) ->
  options =
    autoEdit: false
    editable: true
    enableCellNavigation: true
    enableColumnReorder: false
    forceFitColumns: true
  grid = new Slick.Grid '#slickgrid-container', data, cols, options

IS.onReady "data_sets/edit", ->
  cols = ($ '#slickgrid-container').data 'cols'
  data = ($ '#slickgrid-container').data 'data'
  setupTable cols, data

IS.onReady "data_sets/manualEntry", ->
  cols = ($ '#slickgrid-container').data 'cols'
  setupTable cols, []
