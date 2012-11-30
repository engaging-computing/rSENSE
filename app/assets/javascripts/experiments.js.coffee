# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->
	
	$(".liked_status").click ->
		console.log $(@).children('i')
		icon = $(@).children('i')
		if icon.attr('class').indexOf('icon-star-empty') != -1
				icon.replaceWith('<i class="icon-star"></i>')
		else
				icon.replaceWith('<i class="icon-star-empty"></i>')
		$.ajax
			url: "/experiments/"+$(this).attr("exp_id")+"/updateLikedStatus"
			dataType: "json"
			success: (resp) =>
				console.log resp
				console.log $(@).siblings(".like_display").html resp['update']