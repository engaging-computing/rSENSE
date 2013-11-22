# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  if namespace.controller is "tutorials" and namespace.action is "index"

    ($ '.mainContent').on 'click', 'div.clickableItem', (event) ->
      window.location = ($ event.currentTarget).children('a').attr 'href'

    addItem = (object) ->
      newItem = """
        <div class='item clickableItem'>
          <a href='#{object.url}'></a>
          <div style="padding:7px">
            <div style="font-size:1.2em; font-weight:bold;">#{object.name}
            #{if object.featured then "<span style='color:#57C142'> (featured)</span>" else ""}
            </div>
            <b>Owner: </b><a href='#{object.ownerUrl}'>#{object.ownerName}</a><br />
            <b>Created: </b>#{object.timeAgoInWords} ago (on #{object.createdAt})<br />
          </div>
       </div>
      """

      newItem = ($ newItem)

      ($ '#tutorials').append(newItem).isotope('insert', newItem)

    ($ "#tutorials_search").submit ->
    
      ($ '#hidden_pagination').val(1)
    
      dataObject = ($ this).serialize()
      dataObject += "&per_page=#{constants.INFINITE_SCROLL_ITEMS_PER}"
    
      $.ajax
        url: this.action
        data: dataObject
        dataType: "json"
        success: (data, textStatus)->

          ($ '#tutorials').isotope('remove', ($ '.item'))

          for object in data
            do (object) ->
              addItem object

          helpers.infinite_scroll(data.length, '#tutorials', '#tutorials_search', '#hidden_pagination', '#load_tutorials', addItem)

          ($ window).resize()

      return false

    ($ '.tutorials_sort_select').change ->
      ($ '#tutorials_search').submit()



    grab_ses = (t) ->
      ses = ($ t).attr 'id'
      ses = ses.split '_'
      ses[3]


    ($ ".tutorials_sort_select").change ->
      ($ "#tutorials_search").submit()

    helpers.isotope_layout('#tutorials')
    ($ "#tutorials_search").submit()

    relayout = ->
      helpers.isotope_layout("#tutorials")
      
    ($ window).resize () -> 
      setTimeout(relayout, 750)
      
    ($ '#addProjectButton').click ->
      $.ajax
        url: "tutorials/create"
        data: {}
        dataType: "json"
        success: (data, textStatus) ->
          helpers.name_popup data, "Tutorial", "tutorial"  