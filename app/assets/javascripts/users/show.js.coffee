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

