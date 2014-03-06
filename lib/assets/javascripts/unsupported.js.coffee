#
# Check for unsupported browser
#

$ ->
  if not Modernizr.svg
    text = """
    <div class="alert">
      <button type="button" class="close" data-dismiss="alert">&times;</button>
      You are using an unsupported browser. We recommend the latest version of
      <a href='www.google.com/chrome'>Chrome</a>,
      <a href='www.mozilla.org'>Firefox</a> or
      <a href='http://www.apple.com/safari/'>Safari</a>.
    </div>
    """
    $('body').prepend(text)
