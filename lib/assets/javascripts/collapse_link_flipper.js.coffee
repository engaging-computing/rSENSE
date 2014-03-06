$ ->
  $('.accordion-toggle').click ->
    icon = $(@).children('i')
    if icon.attr('class').indexOf('icon-chevron-down') != -1
      icon.replaceWith('<i class="icon-chevron-up"></i>')
    else
      icon.replaceWith('<i class="icon-chevron-down"></i>')
    
  $('.icon-chevron-down').click (event) ->
    event.preventDefault()
      
  toggle_slider = (slider) ->
    if( ($ slider).parent().find('div.box-content:visible').length == 1 )
      ($ slider).parent().find('div.box-content').slideUp()
      ($ slider).parent().find('div.box-slider i').replaceWith '<i class="icon-chevron-down"></i>'
    else
      ($ slider).parent().find('div.box-content').slideDown()
      ($ slider).parent().find('div.box-slider i').replaceWith '<i class="icon-chevron-up"></i>'
      
  #($ '.box-slider').hide()
        
  ($ '.box-header').click ->
    toggle_slider @

  ($ '.box-slider').click ->
    toggle_slider @
