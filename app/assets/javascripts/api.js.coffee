# Runs on the API documentation page

IS.onReady 'home/api_v1', ->

  # toggle the visibility of the expanding boxes labeled either 'GET' or 'POST'
  ($ '.def').click ->
    expand = ($ this).parent().parent().children '.more'
    expand.toggle()
