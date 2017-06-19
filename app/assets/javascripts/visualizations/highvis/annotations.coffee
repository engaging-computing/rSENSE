$ ->
  if namespace.controller is 'visualizations' and
  namespace.action in ['displayVis', 'embedVis', 'show']

    # Class for an annotation
    # Crucial member variables are the annotation message,
    # along with the associated datapoint and dataset IDs
    # Type indicates whether it is locked onto a datapoint
    # with a callout bubble
    # Also stores the last used x and y points for quick
    # redraws
    class window.Annotation extends Object
        constructor: (msg, ds_id, pt_id, callout = false) ->
            @msg = msg
            @ds_id = ds_id
            @pt_id = pt_id
            @last_x_pt = null
            @last_y_pt = null
            @callout = callout
            
        # Draw the annotation at the chart coordinates
        # Useful for drawing new objects or loading for a vis
        # Important to pass coordinates because units/intervals/etc
        #       depend on what vis is being used, grouping, etc.
        draw: (chart, x_pt = chart.plotLeft, y_pt = chart.plotTop) ->
            @last_x_pt = x_pt
            @last_y_pt = y_pt
            if @callout
                # Calculate pixel positions
                x_px = chart.xAxis[0].toPixels(@last_x_pt)
                y_px = chart.yAxis[0].toPixels(@last_y_pt) 
                # Position of box corner
                x_box = x_px - 20
                if y_px > (chart.chartHeight * .25)
                    y_box = y_px - 40    
                else
                    y_box = y_px + 10
                # Free space
                space = chart.chartWidth - x_box
            else
                x_box = x_pt
                y_box = y_pt
            # Styling stuff (can't use traditional CSS)
            style = {padding: 8, r: 5, zIndex: 6, fill: 'rgba(0, 0, 0, 0.75'}
            text = {color: 'white'}
            # Render new element with class .highcharts-annotation
            render = (x, y) =>
                if @callout
                    elt = chart.renderer.label(@msg, x, y, 'callout', x_px, y_px, false, false, "annotation")
                else
                    elt = chart.renderer.label(@msg, x, y, null, null, null, false, false, "block-annotation")
                elt.attr(style)
                elt.css(text)
                elt.add()
                $(elt.element).draggable()
                return elt
            elt = render x_box, y_box
            
            if @callout and (elt.width > space)
                elt.element.remove()
                overflow = elt.width - space
                render x_box - overflow, y_box



        # Similar to draw, but uses last known coordinates
        # Sufficient for re-drawing on browser resizes which don't change
        #           coordinate system.
        redraw: (chart) ->
            if @last_x_pt isnt null
                @draw chart, @last_x_pt, @last_y_pt


    class window.AnnotationSet extends Object
        constructor: ->
            @list = []
            @ds_id_counter = 0
            @pt_id_counter = 0
        
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

        # For general "rect" annotations, we don't need to associate
        #   with a dataset; however, we still need a unique way to identify it
        generateDsID: () ->
            @ds_id_counter -= 1;
            return @ds_id_counter;
        generatePtID: () ->
            @pt_id_counter -= 1;
            return @pt_id_counter;