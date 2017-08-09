# Place all the behaviors and hooks related to the matching controller here.

IS.onReady "tutorials/index", ->

  # Close sidenav when a link is clicked
  $('.mdl-navigation__link').click ->
    $('.mdl-layout__obfuscator').trigger('click')

  # Fun coloring
  $('.mdl-card').each () ->
    color = 'rgba(' + Math.floor(Math.random() * 256) + ',' \
                    + Math.floor(Math.random() * 256) + ',' \
                    + Math.floor(Math.random() * 256) + ',' \
                    + '0.2)'
    $(this).css('background', color, 'important')
    $(this).css('background', '-moz-linear-gradient(top,  #ffffff 30%, ' + color + ' 100%)', 'important')
    $(this).css('background', '-webkit-linear-gradient(top,  #ffffff 30%, ' + color + ' 100%)', 'important')
    $(this).css('background', 'linear-gradient(to bottom,  #ffffff 30%, ' + color + ' 100%)', 'important')