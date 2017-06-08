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
            text = {color: '#FFFFFF'}
            bubble = {padding: 8, r: 5, zIndex: 100, fill: 'rgba(0, 0, 0, 0.75'}
            x_box = @x_pt - 20;
            y_box = @y_pt - 40;
            chart.renderer.label(@msg, x_box, y_box, @type, @x_pt, @y_pt) \
                          .css(text).attr(bubble) \
                          .add()

    class window.AnnotationSet extends Object
        constructor: ->
            console.log "Creating an annotation set"
            @list = []
        
        addToList: (elt) ->
            @list.push elt

        emptyList: ->
            @list = []