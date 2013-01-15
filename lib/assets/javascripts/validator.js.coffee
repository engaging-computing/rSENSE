$ ->
  ($ 'input.validate_number').live 'change', (event) ->
  
    if isNaN Number event.target.value
      ($ @).addClass 'invalid'
    else
      ($ @).removeClass 'invalid'

  ($ 'input.validate_latitude').live 'change', (event) ->

    val = Number event.target.value
    
    if (isNaN val) or ((Math.abs val) > 90)
      ($ @).addClass 'invalid'
    else
      ($ @).removeClass 'invalid'

  ($ 'input.validate_longitude').live 'change', (event) ->

    val = Number event.target.value

    if (isNaN val) or ((Math.abs val) > 180)
      ($ @).addClass 'invalid'
    else
      ($ @).removeClass 'invalid'

  ($ 'input.validate_timestamp').live 'change', (event) ->

    #Put date validator here
    true