setupTable = () ->
  cols = ($ '#slickgrid-container').data 'cols'
  data = ($ '#slickgrid-container').data 'data'

  console.log cols
  console.log data

  options =
    #autoEdit: false
    editable: true
    enableCellNavigation: true
    enableColumnReorder: false
    forceFitColumns: true

  grid = new Slick.Grid '#slickgrid-container', data, cols, options

IS.onReady "data_sets/edit", ->
  setupTable()

IS.onReady "data_sets/manualEntry", ->
  setupTable()
