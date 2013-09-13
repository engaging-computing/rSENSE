# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  if namespace.controller is "tutorials" and namespace.action is "index"

    addItem = (object) ->
      newItem = """
        <div class='item word-break'>
          <h4 class='center' style='margin-top:0px;'><a href='#{object.url}'>#{object.name}</a>
          #{if object.featured then "<span style='color:#57C142'> (featured)</span>" else ""}</h4>
          #{if object.mediaSrc then "<div class='center'><a href='#{object.url}'><img src='#{object.mediaSrc}'></img></a></div>" else ""}
          <b>Owner: </b><a href='#{object.ownerUrl}'>#{object.ownerName}</a><br />
          <b>Created: </b>#{object.timeAgoInWords} ago (on #{object.createdAt})<br />
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

          if is_admin
            addProjectButton = ($ "<div id='addProjectButton' style='text-align:center;cursor: pointer;' class='item'><img style='width:66%;' class='hoverimage' src='/assets/green_plus_icon.svg'><br /><h4 style='color:#0a0;'>Create Tutorial</h4></img></div>")
            ($ '#tutorials').append(addProjectButton).isotope('insert', addProjectButton)
            ($ '#addProjectButton').click ->
              $.ajax
                url: "tutorials/create"
                data: {}
                dataType: "json"
                success: (data, textStatus) ->
                  helpers.name_popup data, "Tutorial", "tutorial"

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

    ($ window).resize () -> 
      helpers.isotope_layout("#tutorials")