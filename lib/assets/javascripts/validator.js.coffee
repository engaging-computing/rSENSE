$ ->
  ($ '.mainContent').on 'change', 'input.validate_number', (event) ->

    if isNaN Number event.target.value
      ($ @).addClass 'invalid'
    else
      ($ @).removeClass 'invalid'

  ($ '.mainContent').on 'change', 'input.validate_latitude', (event) ->

    val = Number event.target.value

    if (isNaN val) or ((Math.abs val) > 90)
      ($ @).addClass 'invalid'
    else
      ($ @).removeClass 'invalid'

  ($ '.mainContent').on 'change', 'input.validate_longitude', (event) ->

    val = Number event.target.value

    if (isNaN val) or ((Math.abs val) > 180)
      ($ @).addClass 'invalid'
    else
      ($ @).removeClass 'invalid'

  ($ '.mainContent').on 'change', 'input.validate_timestamp', (event) ->

    #Put date validator here
    true

  ($ '.mainContent').on 'change', 'input.validate_text', (event) ->

    true