# Place all the behaviors and hooks related to the users index page here.
$ ->
  if namespace.controller is "users" and namespace.action is "index"

    addItem = (object) ->
      newItem =   "<div class='item' align='center'>"

      newItem +=  "<h4 style='margin-top:0px;'><a href='#{object.url}'>#{helpers.truncate object.username, 16}</a>"

      newItem += "</h4>"

      if (object.gravatar) != null
        newItem += "<a href='#{object.url}'><img src='#{object.gravatar}' /></a><br />"

      newItem +=  "<h8><b>Name: </b><a href='#{object.url}'>#{helpers.truncate object.name, 16}</a></h8><br />"

      newItem +=  "<h8><b>Member Since: </b>#{object.createdAt}</h8><br />"

      newItem +=  "</div>"

      newItem = ($ newItem)

      ($ '#users').append(newItem).isotope('insert', newItem)


    ($ "#users_search").submit ->
    
        ($ '#hidden_pagination').val(1)
    
        dataObject = ($ this).serialize()
        dataObject += "&per_page=#{constants.INFINITE_SCROLL_ITEMS_PER}"
    
        $.ajax
          url: this.action
          data: dataObject
          success: (data, textStatus)->

            ($ '#users').isotope('remove', ($ '.item'))

            for object in data
              do (object) ->
                addItem object

            helpers.infinite_scroll(data.length, '#users', '#users_search', '#hidden_pagination', '#load_users', addItem)


            ($ window).resize()

          dataType: "json"
        return false

    ($ ".users_sort_select").change ->
      ($ "#users_search").submit()

    helpers.isotope_layout('#users')
    ($ "#users_search").submit()

    ($ window).resize () -> 
      helpers.isotope_layout("#users")