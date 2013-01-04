# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  $(".liked_status").click ->
    icon = $(@).children('i')
    if icon.attr('class').indexOf('icon-star-empty') != -1
      icon.replaceWith('<i class="icon-star"></i>')
    else
      icon.replaceWith('<i class="icon-star-empty"></i>')
    $.ajax
      url: "/experiments/"+$(this).attr("exp_id")+"/updateLikedStatus"
      dataType: "json"
      success: (resp) =>
        $(@).siblings(".like_display").html resp['update']

  $("#experiments .pagination a").live("click", ->
      $.getScript(this.href)
      return false)

  $("#experiments_search").submit ->
      $.get(this.action, $(this).serialize(), null, "script")
      return false
      
  $(".experiments_filter_checkbox").click ->
    $("#experiments_search").submit()
    
  $(".experiments_sort_select").change ->
    $("#experiments_search").submit()