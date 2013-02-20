# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->

  ($ '#experiment_templates_search').submit ->
      $.get this.action, ($ this).serialize(), null, 'script'
      false
      
  ($ '.experiment_templates_filter_checkbox').click ->
    ($ '#experiment_templates_search').submit()
    
  ($ '.experiment_templates_sort_select').change ->
    ($ '#experiment_templates_search').submit()

