$ ->
  if namespace.controller is 'visualizations' and
  namespace.action in ['displayVis', 'embedVis', 'show']

    class window.Annotation extends Object
        constructor: (msg, x_pt, y_pt, type = 'rect') ->
            console.log "Creating a new annotation"
            @msg = msg
            @x_pt = x_pt
            @y_pt = y_pt
            if type == 'callout' then @type = 'callout' else @type = 'rect'
            
        draw: (chart) ->
            # X position of box corner
            x_box = @x_pt - 20
            # Y position of box corner
            if @y_pt > (chart.chartHeight / 4)
                y_box = @y_pt - 40    
            else
                y_box = @y_pt + 10
            # Styling stuff (can't use traditional CSS)
            style = {padding: 8, r: 5, zIndex: 6, fill: 'rgba(0, 0, 0, 0.75'}
            text = {color: 'white'}
            # Render new element
            elt = chart.renderer.label(@msg, x_box, y_box, @type, @x_pt, @y_pt, \
                                       false, false, "annotation")
            elt.attr(style)
            elt.css(text)
            elt.add()
            # Set up double-click to delete
            $(elt.element).dblclick =>
                # Remove from data structure
                globals.annotationSet.deleteElement(@x_pt, @y_pt)
                # Remove DOM element
                elt.element.remove()

    class window.AnnotationSet extends Object
        constructor: ->
            console.log "Creating an annotation set"
            @list = []
        
        addToList: (elt) ->
            @list.push elt

        emptyList: ->
            @list = []

        deleteElement: (arg1, arg2) ->
            console.log "Delete called"