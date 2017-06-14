$ ->
  if namespace.controller is 'visualizations' and
  namespace.action in ['displayVis', 'embedVis', 'show']

    class window.Annotation extends Object
        constructor: (msg, ds_id, pt_id, type = 'rect') ->
            @msg = msg
            @ds_id = ds_id
            @pt_id = pt_id
            @x_pt = -1
            if type == 'callout' then @type = 'callout' else @type = 'rect'
            
        # Draw the annotation at the chart coordinates
        # Useful for drawing new objects or loading for a vis
        # Important to pass coordinates because units/intervals/etc
        #       depend on what vis is being used, grouping, etc.
        draw: (chart, x_pt, y_pt) ->
            # Calculate pixel positions
            @x_pt = x_pt
            @y_pt = y_pt
            x_px = chart.xAxis[0].toPixels(@x_pt)
            y_px = chart.yAxis[0].toPixels(@y_pt)
            # X position of box corner
            x_box = x_px - 20
            # Y position of box corner
            if y_px > (chart.chartHeight * .25)
                y_box = y_px - 40    
            else
                y_box = y_px + 10
            # Styling stuff (can't use traditional CSS)
            style = {padding: 8, r: 5, zIndex: 6, fill: 'rgba(0, 0, 0, 0.75'}
            text = {color: 'white'}
            # Render new element with class .highcharts-annotation
            @elt = chart.renderer.label(@msg, x_box, y_box, @type, x_px, y_px, \
                                       false, false, "annotation")
            @elt.attr(style)
            @elt.css(text)
            @elt.add()

        # Similar to draw, but uses last known coordinates
        # Sufficient for re-drawing on browser resizes which don't change
        #           coordinate system.
        redraw: (chart) ->
            if @x_pt isnt -1
                @elt.element.remove()
                x_px = chart.xAxis[0].toPixels(@x_pt)
                y_px = chart.yAxis[0].toPixels(@y_pt)
                x_box = x_px - 20
                if y_px > (chart.chartHeight * .25)
                    y_box = y_px - 40    
                else
                    y_box = y_px + 10
                style = {padding: 8, r: 5, zIndex: 6, fill: 'rgba(0, 0, 0, 0.75'}
                text = {color: 'white'}
                @elt = chart.renderer.label(@msg, x_box, y_box, @type, x_px, y_px, \
                                        false, false, "annotation")
                @elt.attr(style)
                @elt.css(text)
                @elt.add()


    class window.AnnotationSet extends Object
        constructor: ->
            @list = []
        
        addToList: (elt) ->
            @list.push elt

        # Checks list membership
        hasAnnotationAt: (id1, id2) ->
            idx = @list.findIndex (elt) ->
                (elt.ds_id == id1) and (elt.pt_id == id2)
            not (idx == -1)

        # Similar, but returns element
        getElement: (id1, id2) ->
            idx = @list.findIndex (elt) ->
                (elt.ds_id == id1) and (elt.pt_id == id2)
            if (idx isnt -1)
                @list[idx]
            else
                null

        deleteElement: (id1, id2) ->
            idx = @list.findIndex (elt) ->
                (elt.ds_id == id1) and (elt.pt_id == id2)
            if idx isnt -1
                @list.splice idx, 1

        redrawAll: (chart) ->
            for elt in @list
                elt.redraw(chart)