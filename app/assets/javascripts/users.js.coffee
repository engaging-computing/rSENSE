# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$ ->
    $("#users .pagination a").live("click", ->
        $.getScript(this.href)
        return false)
        
    $("#users_search").submit ->
        $.get(this.action, $(this).serialize(), null, "script")
        return false

    $(".users_sort_select").change ->
      $("#users_search").submit()
      
      
    $(".mystuff_sort_select").change ->
      $("#mystuff_search").submit()
    
    $("#mystuff_search").submit ->
      $.get("/users/jim", $(this).serialize(), null, "script")
      return false