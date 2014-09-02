setupTable = () ->
  data = for i in [0..200]
    a: i * 3
    b: i * 3 + 1
    c: i * 3 + 2

  columns = [
    {id: 'a', field: 'a', name: 'a', editor: Slick.Editors.Text}
    {id: 'b', field: 'b', name: 'b', editor: Slick.Editors.Integer}
    {id: 'c', field: 'c', name: 'c', editor: Slick.Editors.Text}
  ]

  options =
    autoEdit: false
    editable: true
    enableCellNavigation: true
    enableColumnReorder: false

  grid = new Slick.Grid '#slickgrid-container', data, columns, options

IS.onReady "data_sets/edit", ->
  setupTable()

IS.onReady "data_sets/manualEntry", ->
  setupTable()
