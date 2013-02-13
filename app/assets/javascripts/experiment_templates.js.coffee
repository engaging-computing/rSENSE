# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->

  ($ '#experiments_search').submit ->
      $.get this.action, ($ this).serialize(), null, 'script'
      false
      
  ($ '.experiments_filter_checkbox').click ->
    ($ '#experiments_search').submit()
    
  ($ '.experiments_sort_select').change ->
    ($ '#experiments_search').submit()

