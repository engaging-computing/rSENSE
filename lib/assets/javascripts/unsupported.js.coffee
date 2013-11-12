# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/


$ ->
  if Modernizr.svg
      text = """
      <div class="alert">
        <button type="button" class="close" data-dismiss="alert">&times;</button>
        You are using an unsupported browser. We recommend the latest versions of <a href='www.google.com/chrome'>Chrome</a>, <a href='www.mozilla.org'>Firefox</a> or <a href='http://www.apple.com/safari/'>Safari</a>.
      </div>
      """
      $('body').prepend(text);
