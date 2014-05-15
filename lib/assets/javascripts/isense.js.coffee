
window.IS ||= {}

#
# Page namespacing of Ready events,
# Turbolinks aware.
#

IS.readyEvents = {}
IS.setupEvents = []

IS.onReady = (page, fn) ->
  IS.readyEvents[page] ||= []
  IS.readyEvents[page].push fn

IS.onSetup = (fn) ->
  IS.setupEvents.push fn

runPageReady = () ->
  fn() for fn in IS.setupEvents

  page = $('body').attr('data-page-name')
  code = IS.readyEvents[page]
  if code?
    fn() for fn in code

$(document).on("ready page:load", runPageReady)

#
# Helpers for handlebars templates.
#
#

IS.onSetup ->
  IS.tmpl = {}
  
  $('script').each (ii, ss) ->
    if $(ss).attr('data-template-name')?
      name = $(ss).attr('data-template-name')
      tmpl = Handlebars.compile($(ss).html())
      IS.tmpl[name] = tmpl

  IS.fillTmpl = (elem, name, attrs) ->
    $(elem).html(IS.tmpl[name](attrs))
