################################################################################
# Color Picker HTML                                                            #
################################################################################

cpBody = '''<div id="colorpicker">
    <div class="sv-picker">
      <div class="gradient"></div>
      <div class="h sline"></div>
      <div class="v sline"></div>
      <div class="h line"></div>
      <div class="v line"></div>
    </div>
    <div class="h-picker">
      <div class="gradient"></div>
      <div class="h sline"></div>
      <div class="h line"></div>
    </div>
    <div class="preview"></div>
    <div class="mbutton msubmit">Save</div>
    <div class="mbutton mcancel">Exit</div>
  </div>'''

EDIT_NONE   = 0
EDIT_HUE    = 1
EDIT_SATVAL = 2
EDIT_OPEN = 3

################################################################################
# Helper function - fill in the rest of the arguments                          #
################################################################################

addDefaults = (args, defaults) ->
  if args == undefined
    args = {}
  for x of defaults
    unless x of args
      args[x] = defaults[x]
  args

################################################################################
# JQuery tie-in                                                                #
################################################################################

$.fn.extend
  colorpicker: (args) ->
    args = addDefaults args,
      onOpen: ->
      onChange: (val) ->
      onSubmit: (val) ->
      onClose: (val) ->
      hPosition: (w, h) ->
        100
      vPosition: (w, h) ->
        100
      zPosition: 1
      anchor: $('body')
      autoClose: true
      outputType: 'rgb'

    args.this = @

    colorPicker = $(document).data 'better_colorpicker'
    if colorPicker == undefined
      colorPicker = new ColorPicker()
      $(document).data 'better_colorpicker', colorPicker

    colorRef = new ColorPickerRef args, colorPicker
    colorRef

################################################################################
# The actual ColorPicker UI element.                                           #
# Only one of these ever exists on the page.  To interface with the            #
#   ColorPicker, use ColorPickerRef.                                           #
################################################################################

class ColorPicker
  color: {h: 0, s: 1, v: 1}
  loadColor: {h: 0, s: 1, v: 1}
  dragMode: EDIT_NONE
  jqObj: null
  anchor: null

  constructor: ->
    @jqObj = $(cpBody)

  # methods
  openMenu: (x, y, color, anchor, autoClose, @args) =>
    pAnchor = if @anchor == null then null else @anchor[0]
    if anchor[0] isnt pAnchor
      @anchor = anchor
      @anchor.css
        position: 'relative'
      @jqObj.remove()
      anchor.append @jqObj

    tempColor = @inputColor color
    if tempColor.isValid()
      @color = tempColor.toHsv()
      @color.h /= 360
    else
      @color = {h: 0, s: 1, v: 1}
    
    @args.onChange @outputColor @color

    @loadColor = {h: @color.h, s: @color.s, v: @color.v}

    @jqObj.show()
    @jqObj.css
      top: x
      left: y

    @dragMode = EDIT_OPEN

    $(document).on 'mousemove.better_colorpicker', @dragChange
    $(document).on 'mouseup.better_colorpicker', (e) =>
      distPicker = $(e.target).closest('#colorpicker').length
      distButton = $(e.target).closest(args.this).length
      if @dragMode == EDIT_HUE or @dragMode == EDIT_SATVAL
        @dragEnd e
      else if autoClose and distPicker == 0 and distButton == 0
        @closeMenu()
    @jqObj.find('.h-picker').on 'mousedown.better_colorpicker', @dragStartHue
    @jqObj.find('.sv-picker').on 'mousedown.better_colorpicker', @dragStartSat
    @jqObj.find('.msubmit').on 'click.better_colorpicker', @submitColor
    @jqObj.find('.mcancel').on 'click.better_colorpicker', @cancelChange

    @adjustPickers()

  closeMenu: =>
    @args.onClose @outputColor @color

    @jqObj.hide()
    $(document).off 'click.better_colorpicker'
    $(document).off 'mousemove.better_colorpicker'
    $(document).off 'mouseup.better_colorpicker'
    @jqObj.find('.h-picker').off 'click.better_colorpicker'
    @jqObj.find('.sv-picker').off 'click.better_colorpicker'
    @jqObj.find('.msubmit').off 'click.better_colorpicker'
    @jqObj.find('.mcancel').off 'click.better_colorpicker'

  # DOM functions
  adjustPickers: =>
    hsv = {h: @color.h, s: @color.s, v: @color.v}

    # adjust the preview color and border
    borderColor = {h: @color.h, s: @color.s, v: @color.v}
    if Math.sqrt(Math.pow(hsv.s, 2) + Math.pow(1 - hsv.v, 2)) < 0.2
      t = Math.atan(hsv.s / (1 - hsv.v + 0.000001))
      borderColor.s = 0.2 * Math.sin(t)
      borderColor.v = 1 - (0.2 * Math.cos(t))
    @jqObj.find('.preview').css
      backgroundColor: tinycolor.fromRatio(hsv).toHexString()
      borderColor: tinycolor.fromRatio(borderColor).toHexString()

    # adjust the color of the sv picker
    hsv = {h: @color.h, s: @color.s, v: @color.v}
    @jqObj.find('.sv-picker > .gradient').css
      backgroundColor: tinycolor.fromRatio({h: hsv.h, s: 1, v: 1, a: 1}).toHexString()

    # adjust the position of the sliders on the sv and h pickers
    hl = @jqObj.find '.h-picker > .h'
    hl.css top: hsv.h * (hl.parent().height() - 3) + 1

    sl = @jqObj.find '.sv-picker > .v'
    sl.css left: hsv.s * (sl.parent().width() - 3) + 1

    vl = @jqObj.find '.sv-picker > .h'
    vl.css top: (1 - hsv.v) * (vl.parent().height() - 3) + 1 

  selectColor: (menu, x, y) =>
    if menu.hasClass 'sv-picker'
      hPos = Math.max(1, Math.min(x - menu.offset().left, menu.width() - 1)) - 1
      vPos = Math.max(1, Math.min(y - menu.offset().top, menu.height() - 1)) - 1
      @color.s = hPos / (menu.width() - 2)
      @color.v = 1 - vPos / (menu.height() - 2)
    else if menu.hasClass 'h-picker'
      vPos = Math.max(1, Math.min(y - menu.offset().top, menu.height() - 1)) - 1
      @color.h = vPos / (menu.height() - 2)

  # event handlers
  dragStartHue: (e) =>
    @dragMode = EDIT_HUE
    $('body').addClass 'disable-text-select'
    @dragChange e

  dragStartSat: (e) =>
    @dragMode = EDIT_SATVAL
    $('body').addClass 'disable-text-select'
    @dragChange e

  dragChange: (e) =>
    currEdit = switch @dragMode
      when EDIT_SATVAL then @jqObj.find('.sv-picker')
      when EDIT_HUE    then @jqObj.find('.h-picker')
      else null

    unless currEdit?
      return

    @selectColor currEdit, e.pageX, e.pageY
    @adjustPickers()
    @args.onChange @outputColor @color

  dragEnd: =>
    if @dragMode == EDIT_HUE or @dragMode == EDIT_SATVAL
      @dragMode = EDIT_NONE
    $('body').removeClass 'disable-text-select'

  dragPostEnd: =>
    @dragMode = EDIT_NONE

  submitColor: =>
    @args.onSubmit @outputColor @color
    @closeMenu()

  cancelChange: =>
    @color = @loadColor
    @closeMenu()

  # helper functions
  inputColor: (color) ->
    tinycolor(color)

  outputColor: (color) ->
    dup = {h: color.h, s: color.s, v: color.v, a: 1}
    switch @outputType
      when 'hex' then tinycolor.fromRatio(dup).toHexString()
      else tinycolor.fromRatio(dup).toHexString()


################################################################################
# A reference to a particular instance of a ColorPicker plus information       #
#   relating to that ColorPicker.                                              #
################################################################################

class ColorPickerRef
  args: null
  elem: null
  isOpen: false

  constructor: (@args, @elem) ->
    onOpen = @args.onOpen
    onChange = @args.onChange
    onClose = @args.onClose
    onSubmit = @args.onSubmit

    @args.onOpen = =>
      @isOpen = true
      onOpen()

    @args.onChange = (val) =>
      onChange val

    @args.onClose = (val) =>
      @isOpen = false
      onClose val

    @args.onSubmit = (val) =>
      @isOpen = false
      onSubmit val

  open: ->
    unless @isOpen
      @elem.openMenu 0, 0, @args.onOpen(), @args.anchor, @args.autoClose, @args

      x = @args.hPosition @elem.jqObj.outerWidth(), @elem.jqObj.outerHeight()
      y = @args.vPosition @elem.jqObj.outerWidth(), @elem.jqObj.outerHeight()

      @elem.jqObj.css
        left: x
        top: y
        zIndex: @args.zPosition
    else
      @close()

  close: ->
    @elem.closeMenu()
