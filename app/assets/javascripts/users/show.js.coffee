# Place all the behaviors and hooks related to the users show page here.    
$ ->
  if namespace.controller is "users" and namespace.action is "show" 
    $(".contribution_sort_select").change ->
      $("#contribution_search").submit()
      
    $("#contribution_search").submit ->
      $.get("/users/#{$(this).attr('name')}", $(this).serialize(), null, "script")
      return false
        
    $(".contribution_type_checkbox").click ->
      $("#contribution_search").submit()

