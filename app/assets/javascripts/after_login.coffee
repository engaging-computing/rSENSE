$(document).ready () ->
  $('#set_email_preference').show()
  $.ui.dialog.prototype._focusTabbable = () -> {}
  $('#set_email_preference').dialog({
    modal: true,
    title: 'Email Preference',
    closeOnEscape: false,
    open: (event, ui) ->
      $(".ui-dialog-titlebar-close", ui.dialog | ui).hide()
    })
