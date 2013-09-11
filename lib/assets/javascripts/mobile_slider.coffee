$ ->
  ($ '#mobile_menu').toggle 'slide'
  
  ($ '#mobile_menu_trigger').click ->
    ($ '#mobile_menu').toggle 'slide'
  
  ($ '#mobile_menu_trigger').bind 'vclick', ->
    ($ '#mobile_menu_trigger').trigger 'click'