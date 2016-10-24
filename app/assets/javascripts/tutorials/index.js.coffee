# Place all the behaviors and hooks related to the matching controller here.

IS.onReady "tutorials/index", ->

  # Close sidenav when a link is clicked
  $('.mdl-navigation__link').click ->
    $('.mdl-layout__obfuscator').trigger('click')
