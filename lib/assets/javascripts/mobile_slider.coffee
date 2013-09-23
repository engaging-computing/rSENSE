$ ->
  ($ '#mobile_menu').addClass 'transition_timer'
  ($ '#mobile_menu').addClass 'panel_left'

  
  ($ '#mobile_menu_trigger').click ->
    if ($ '#mobile_menu').hasClass('panel_right')
      ($ '#mobile_menu').removeClass 'panel_right'
      ($ '#mobile_menu').addClass 'panel_left'
    else
      ($ '#mobile_menu').removeClass 'panel_left'
      ($ '#mobile_menu').addClass 'panel_right'
    
  
  ($ '#mobile_menu_trigger').bind 'vclick', ->
    ($ '#mobile_menu_trigger').trigger 'click'