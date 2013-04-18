# Place all the behaviors and hooks related to the users show page here.    
$ ->  
      
  $(".contribution_sort_select").change ->
    $("#contribution_search").submit()
    
  $("#contribution_search").submit ->
    $.get("/users/#{$(this).attr('name')}", $(this).serialize(), null, "script")
    return false
      
  $(".contribution_type_checkbox").click ->
    $("#contribution_search").submit()

