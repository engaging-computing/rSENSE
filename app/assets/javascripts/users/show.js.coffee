# Place all the behaviors and hooks related to the users show page here.    
$ ->
  if namespace.controller is "users" and namespace.action is "show" 
  
    $(".contribution_sort_select").change ->
      $("#contribution_search").submit()
      
    $("#contribution_search").submit ->
      $.ajax
        url: "/users/#{$(this).attr('name')}/contributions"
        data: $(this).serialize()
        dataType: "html"
        success: (dat) ->
          $("#contributions").html dat
          
      return false
        
    $(".contribution_type_checkbox").click ->
      $("#contribution_search").submit()
      
    $("#contribution_search").submit()
    
    ###
    Links for Contributions
    ###
    ($ '.mainContent').on 'click', 'a.contribution_hide', (e) ->
    
      e.preventDefault()
      
      data = {}
      data[($ @).attr 'type'] =
        hidden: true
      
      $.ajax
        url: ($ @).attr('href')
        type: 'PUT'
        dataType: "json"
        data: data
        success: =>
          ($ @).removeClass 'contribution_hide'
          ($ @).addClass 'contribution_unhide'
          ($ @).html('Unhide')
          
    ($ '.mainContent').on 'click', 'a.contribution_unhide', (e) ->
    
      e.preventDefault()
      
      data = {}
      data[($ @).attr 'type'] =
        hidden: false
      
      $.ajax
        url: ($ @).attr('href')
        type: 'PUT'
        dataType: "json"
        data: data
        success: =>
          ($ @).addClass 'contribution_hide'
          ($ @).removeClass 'contribution_unhide'
          ($ @).html('Hide')
          
    ($ '.mainContent').on 'click', 'a.contribution_delete', (e) ->
  
      e.preventDefault()
      
      if helpers.confirm_delete ($ @).parents('div.contribution').find('h4 a').html()
        $.ajax
          url: ($ @).attr('href')
          type: 'DELETE'
          dataType: "json"
          success: =>
            ($ @).parents('div.contribution').hide_row () =>
              ($ 'div#contributions div.contribution').filter(':visible').each (idx) ->
                if idx % 2 is 0
                  ($ @).addClass 'feed-even'
                  ($ @).removeClass 'feed-odd'
                else
                  ($ @).removeClass 'feed-even'
                  ($ @).addClass 'feed-odd'

