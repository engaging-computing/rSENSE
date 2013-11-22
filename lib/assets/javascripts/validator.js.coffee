$ ->
  ($ '.mainContent').on 'change', 'input.validate_number', (event) ->

    if isNaN Number event.target.value
      ($ @).addClass 'invalid'
      ($ @).popover
        content: "Not a valid number."
        trigger: "focus"
        placement: "top"
        container: "body"
    else
      ($ @).removeClass 'invalid'
      ($ @).popover("destroy")

  ($ '.mainContent').on 'change', 'input.validate_latitude', (event) ->

    val = Number event.target.value

    if (isNaN val) or ((Math.abs val) > 90)
      ($ @).addClass 'invalid'
      ($ @).popover
        content: "Not a valid latitude."
        trigger: "focus"
        placement: "top"
        container: "body"
    else
      ($ @).removeClass 'invalid'
      ($ @).popover("destroy")

  ($ '.mainContent').on 'change', 'input.validate_longitude', (event) ->

    val = Number event.target.value

    if (isNaN val) or ((Math.abs val) > 180)
      ($ @).addClass 'invalid'
      ($ @).popover
        content: "Not a valid longitude."
        trigger: "focus"
        placement: "top"
        container: "body"
    else
      ($ @).removeClass 'invalid'
      ($ @).popover("destroy")

  ($ '.mainContent').on 'change', 'input.validate_timestamp', (event) ->

    #Put date validator here
    val = event.target.value
    dat = (helpers.parseTimestamp val)
    
    if val is ""
      ($ @).removeClass 'invalid'
      ($ @).popover("destroy")
    else
      if (typeof dat is "number") and (isNaN dat)
        ($ @).addClass 'invalid'
        ($ @).popover
          content: "Not a valid timestamp."
          trigger: "focus"
          placement: "top"
          container: "body"
      else
        ($ @).removeClass 'invalid'
        ($ @).popover("destroy")

  ($ '.mainContent').on 'change', 'input.validate_text', (event) ->

    true