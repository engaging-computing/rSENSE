# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  if namespace.controller is "visualizations" and namespace.action is "index"

    ($ '.mainContent').on 'click', 'div.clickableItem', (event) ->
      window.location = ($ event.currentTarget).children('a').attr 'href'

    addItem = (object) ->
      newItem = """
        <div class='item clickableItem'>
          <a href='#{object.url}'></a>
          #{if object.mediaSrc then "<div class='caroucell' style='height:120px; background-image:url(#{object.mediaSrc})'></div>" else ""}
          <div style="padding:7px">
            <div style="font-size:1.2em; font-weight:bold;">#{object.name}</div>
            #{if object.featured then "<span style='color:#57C142'> (featured)</span><br>" else ""}
            <b>Owner: </b><a href='#{object.ownerUrl}'>#{object.ownerName}</a><br />
            <b>Project: </b><a href='#{object.projectUrl}'>#{object.projectName}</a><br />
            <b>Created: </b>#{object.timeAgoInWords} ago (on #{object.createdAt})<br />
          </div>
       </div>
      """
      
      newItem = ($ newItem)

      ($ '#visualizations').append(newItem).isotope('insert', newItem)

    ($ "#visualizations_search").submit ->
      
        ($ '#hidden_pagination').val(1)
    
        dataObject = ($ this).serialize()
        dataObject += "&per_page=#{constants.INFINITE_SCROLL_ITEMS_PER}"
    
        $.ajax
          url: this.action
          data: dataObject
          dataType: "json"
          success: (data, textStatus)->

            ($ '#visualizations').isotope('remove', ($ '.item'))

            for object in data
              do (object) ->
                addItem object

            helpers.infinite_scroll(data.length, '#visualizations', '#visualizations_search', '#hidden_pagination', '#load_visualizations', addItem)

            $(window).resize()

        return false

    ($ '.visualizations_filter_checkbox').click ->
      ($ '#visualizations_search').submit()

    ($ '.visualizations_sort_select').change ->
      ($ '#visualizations_search').submit()

    ($ ".visualizations_sort_select").change ->
      ($ "#visualizations_search").submit()

    helpers.isotope_layout('#visualizations')
    ($ "#visualizations_search").submit()

    ($ window).resize () ->
      helpers.isotope_layout("#visualizations")
