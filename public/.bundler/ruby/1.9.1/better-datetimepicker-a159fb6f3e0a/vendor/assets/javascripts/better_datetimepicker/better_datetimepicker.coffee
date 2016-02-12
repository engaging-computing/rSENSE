################################################################################
# datetimepicker html                                                          #
################################################################################

yMin = -100000
yMax = 100000

dtBody = '''<div id='dt-picker'>
    <div id='dt-date-group'>
      <div class='dt-horiz-picker'>
        <div class='dt-arrow' data-next-month='-1'><i class='fa fa-chevron-left'></i></div>
        <div class='dt-value'>
          <input id='dt-month-textbox' readonly type='text'/>
        </div>
        <div class='dt-value'>
          <input id='dt-year-textbox' type='text' />
        </div>
        <div class='dt-arrow' data-next-month='1'><i class='fa fa-chevron-right'></i></div>
      </div>
      <table>
        <thead><tr><th>Su</th><th>Mo</th><th>Tu</th><th>We</th><th>Th</th><th>Fr</th><th>Sa</th></tr></thead>
      </table>
    </div>
    <div id='dt-time-group'>
      <input id='dt-time-textbox' type='text' />
      </select>
    </div>
  </div>'''

validTimeFormats = ['h:mm:ss A', 'h:mm:ss a', 'hh:mm:ss A', 'hh:mm:ss a', 'h:mm A', 'h:mm a', 'hh:mm A', 'hh:mm a']


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
# jQuery tie-in                                                                #
# args:                                                                        #
#   input: a callback that should return an ISO-formatted string representing  #
#          a time, or an empty string to represent the current time            #
#   output: a callback that takes an argument in the form of an ISO-formatted  #
#          string representing the chosen time                                 #
#   position: a string ('left', 'center', 'right') that determines where the   #
#          datetimepicker will be positioned                                   #
################################################################################

$.fn.extend
  datetimepicker: (args) ->
    # supply defaults if needed
    args = addDefaults args,
      keyEventOn: (e) ->
        $(document).on 'keyup.better_datetimepicker', e
      keyEventOff: ->
        $(document).off 'keyup.better_datetimepicker'
      keyPress: (e) ->
        e.keyCode
      onOpen: ->
        moment()
      onChange: (newTime) ->
      onClose: (newTime) ->
      onKeys:
        13: (e) ->
          dtRef.close()
      anchor: $('body')
      autoClose: true
      hPosition: 'alignLeft'
      vPosition: 'bottomOf'
      minYear: -100000
      maxYear: 100000

    args.this = @

    # create the actual datetimepicker if needed - only one should ever exist
    dtPicker = $(document).data 'better_datetimepicker'
    if dtPicker == undefined
      dtPicker = new DateTimePicker()
      $(document).data 'better_datetimepicker', dtPicker

    dtRef = new DateTimePickerRef(args, dtPicker)
    dtRef



################################################################################
# The actual DateTimePicker UI element.                                        #
# Only one of these ever exists on the page.  To interface with the            #
#   DateTimePicker, use DateTimePickerRef.                                     #
################################################################################

class DateTimePicker
  time: moment()  # current MomentJS time object
  jqObj: null     # jQuery object for DTPicker UI element
  skip: false     # handles DOM abnormalities relating to opening
  anchor: null
  args: {}
  changeEvent: (val) ->
  closeEvent: (val) ->
  keyEvents: {}
  keyBlocks: {}

  constructor: ->
    @jqObj = $(dtBody)
    @buildCalendar()
    @buildMonthList()
    @buildYearList()
    @buildTimeList()
    #@openMenu 100, 100, @time, $('#slickgrid-container > .slick-viewport')

  # methods
  openMenu: (x, y, time, anchor, autoClose, @args) =>
    if anchor != @anchor
      @anchor = anchor
      @anchor.css
        position: 'relative'
      @jqObj.remove()
      anchor.append @jqObj

    unixRegex = /u (\d+)/
    test = unixRegex.exec(time)
    @time = if test != null
      moment parseInt test[1]
    else
      moment time

    unless @time.isValid()
      @time = moment()
      @args.onChange(@time)

    @jqObj.show()
    @jqObj.css
      top: x
      left: y

    if autoClose
      $(document).on 'click.better_datetimepicker', (e) =>
        if $(e.target).closest('#dt-picker').length == 0
          @closeMenu()

    @jqObj.find('.dt-arrow').on 'click.better_datetimepicker', @arrowPick
    @jqObj.find('#dt-date-group').on 'click.better_datetimepicker', 'td', @calendarPick
    @jqObj.find('#dt-month-textbox').on 'click.better_datetimepicker', @openSelectMenu @jqObj.find('#dt-month-textbox'), @jqObj.find('#dt-month-select')
    @jqObj.find('#dt-year-textbox').on 'click.better_datetimepicker', @openSelectMenu @jqObj.find('#dt-year-textbox'), @jqObj.find('#dt-year-select')
    @jqObj.on 'change.better_datetimepicker', '#dt-month-select', @selectFromMenu @jqObj.find('#dt-month-textbox'), 'month'
    @jqObj.on 'change.better_datetimepicker', '#dt-year-select', @selectFromMenu @jqObj.find('#dt-year-textbox'), 'year'
    @jqObj.on 'change.better_datetimepicker', '#dt-time-select', @selectFromMenu @jqObj.find('#dt-time-textbox'), 'time'
    @jqObj.on 'keyup.better_datetimepicker', '#dt-year-textbox', @enterValue @jqObj.find('#dt-year-textbox'), 'year'
    @jqObj.on 'keyup.better_datetimepicker', '#dt-time-textbox', @enterValue @jqObj.find('#dt-time-textbox'), 'time'
    @jqObj.on 'blur.better_datetimepicker', '#dt-time-textbox', @enterValue @jqObj.find('#dt-time-textbox'), 'time'
    @jqObj.on 'blur.better_datetimepicker', '#dt-year-textbox', @enterValue @jqObj.find('#dt-year-textbox'), 'year'

    @args.keyEventOn @handleKeys

    @buildCalendar()
    @buildMonthList()
    @buildYearList()
    @buildTimeList()

  closeMenu: ->
    @args.onClose(@time)
    @jqObj.hide()
    $(document).off 'click.better_datetimepicker'
    @jqObj.find('.dt-arrow').off 'click.better_datetimepicker'
    @jqObj.find('#dt-date-group table').off 'click.better_datetimepicker'
    @jqObj.find('#dt-month-textbox').off 'click.better_datetimepicker'
    @jqObj.find('#dt-year-textbox').off 'click.better_datetimepicker'
    @jqObj.off 'click.better_datetimepicker'
    @jqObj.off 'keyup.better_datetimepicker'
    @jqObj.off 'blur.better_datetimepicker'

    @args.keyEventOff @handleKeys

  # DOM functions
  buildCalendar: =>
    # get a reference to the DOM object (or create one if needed) for the calendar
    table = if @jqObj.find('tbody').length == 0
      weeks = for week in [0..5]
        days = for day in [0..6]
          '<td></td>'
        "<tr>#{days.join ''}</tr>"
      $("<tbody>#{weeks.join ''}</tbody>")
    else
      @jqObj.find('#dt-date-group tbody').remove()

    # construct a 42-element array of dates to use in the calendar
    dates = []
    currDate  = moment(@time).startOf('month').startOf('week')
    currMonth = @time.month()
    for i in [0..41]
      m = currDate.month() - currMonth
      if m < -1
        m += 12
      else if m > 1
        m -= 12
      dates.push
        date:  currDate.date()
        month: m
      currDate.add 1, 'days'

    # update the DOM object to display the dates of the current month
    for i in table.find 'tr'
      for j in $(i).find 'td'
        newDate = dates.shift()
        $(j).text newDate.date
        $(j).attr 'data-date',  newDate.date
        $(j).attr 'data-month', newDate.month
        if newDate.date == @time.date() and newDate.month == 0
          $(j).addClass 'dt-select'
          $(j).removeClass 'dt-inactive'
        else if newDate.month == 0
          $(j).removeClass 'dt-select'
          $(j).removeClass 'dt-inactive'
        else
          $(j).removeClass 'dt-select'
          $(j).addClass 'dt-inactive'

    # put the DOM object in the table
    @jqObj.find('#dt-date-group table').append table

  buildMonthList: =>
    interval = 1 # months to increment the date by
    total = 12  # months in a year
    scrollPos = 0

    # get a reference to the DOM object (or create one if needed) for the month list
    list = if @jqObj.find('#dt-month-select').length == 0
      times = for i in [1 .. total / interval]
        '<option></option>'
      select = $("<select>#{times.join ''}</select>")
      select.attr 'id', 'dt-month-select'
      select.attr 'size', '2'
    else
      obj = @jqObj.find('#dt-month-select')
      scrollPos = obj.scrollTop()
      obj.remove()

    timeObj = moment().startOf('year')
    for i in list.find 'option'
      $(i).text timeObj.format 'MMMM'
      $(i).attr 'data-month', timeObj.month()
      if timeObj.month() == @time.month()
        $(i).attr 'selected', true
      timeObj.add interval, 'months'

    @jqObj.find('#dt-month-textbox').parent().append list
    list.scrollTop scrollPos
    @updateMonthInput()

  buildYearList: =>
    interval = 1
    maxSpan = 5
    scrollPos = 0

    # calculate which years to put in the dropdown
    rMin = @time.year() - maxSpan
    rMax = @time.year() + maxSpan

    if rMin < yMin and rMax > yMax
      # contract window from both sides
      rMin = yMin
      rMax = yMax
    else if rMin < yMin
      # shift window up
      rMax = Math.min(yMax, rMax + (yMin - rMin))
      rMin = yMin
    else if rMax > yMax
      # shift window down
      rMin = Math.max(yMin, rMin - (rMax - yMax))
      rMax = yMax
    years = [rMin .. rMax]

    # get a reference to the DOM object (or create one if needed) for the year list
    list = if @jqObj.find('#dt-year-select').length == 0
      curr = for i in [1 .. years.length]
        '<option></option>'
      select = $("<select>#{curr.join ''}</select>")
      select.attr 'id', 'dt-year-select'
      select.attr 'size', '2'
    else
      # make sure that there are enough options if the selector exists
      obj = @jqObj.find('#dt-year-select')
      scrollPos = obj.scrollTop()
      curr = obj.remove()
      if curr.children.length > years.length
        for i in [curr.children.length .. years.length]
          curr.children("*:nth-child(#{i})").remove()
      else if curr.children().length < years.length
        for i in [years.length .. curr.children.length]
          curr.append $('<option></option>')
      curr

    # update the list of years
    for i in list.find 'option'
      newYear = years.shift()
      $(i).text newYear
      $(i).attr 'data-year', newYear
      if newYear == @time.year()
        $(i).attr 'selected', true

    @jqObj.find('#dt-year-textbox').parent().append list
    list.scrollTop scrollPos
    @updateYearInput()

  buildTimeList: =>
    interval = 30 # minutes to increment the time by
    total = 1440  # minutes in a day
    scrollPos = 0

    list = if @jqObj.find('#dt-time-select').length == 0
      times = for i in [1 .. total / interval]
        '<option></option>'
      select = $("<select>#{times.join ''}</select>")
      select.attr 'id', 'dt-time-select'
      select.attr 'size', '2'
    else
      obj = @jqObj.find '#dt-time-select'
      scrollPos = obj.scrollTop()
      obj.remove()

    timeObj = moment().startOf('day')
    for i in list.find 'option'
      minuteCount1 = @time.minute() + @time.hour() * 60
      minuteCount2 = timeObj.minute() + timeObj.hour() * 60
      minuteDelta = Math.abs minuteCount1 - minuteCount2
      if minuteDelta < 30
        $(i).attr 'selected', true

      $(i).text timeObj.format 'h:mm A'
      $(i).attr 'data-hour', timeObj.hour()
      $(i).attr 'data-minute', timeObj.minute()
      timeObj.add interval, 'minutes'

    @jqObj.find('#dt-time-textbox').parent().append list
    list.scrollTop scrollPos
    @updateTimeInput()

  updateMonthInput: (e) =>
    @jqObj.find('#dt-month-textbox').val @time.format 'MMMM'

  updateYearInput: (e) =>
    @jqObj.find('#dt-year-textbox').val @time.year()

  updateTimeInput: (e) =>
    if @time.seconds() == 0
      @jqObj.find('#dt-time-textbox').val @time.format 'h:mm A'
    else
      @jqObj.find('#dt-time-textbox').val @time.format 'h:mm:ss A'

  # event handlers
  arrowPick: (e) =>
    dir = parseInt $(e.target).closest('.dt-arrow').attr 'data-next-month'
    @time.add dir, 'months'
    @buildCalendar()
    @buildMonthList()
    @buildYearList()
    @args.onChange @time

  calendarPick: (e) =>
    td = $(e.target)
    dir = parseInt td.attr('data-month')
    if dir == 0
      @time.date parseInt td.attr 'data-date'
      active = td.closest('tbody').find('.dt-select')
      active.removeClass 'dt-select'
      td.addClass 'dt-select'
    else
      @time.add dir, 'months'
      @time.date parseInt td.attr 'data-date'
      @buildCalendar()
      @buildMonthList()
      @buildYearList()
    @args.onChange @time

  openSelectMenu: (field, dropdown) =>
    event_name = "click.better_datetimepicker_openselectmenu_#{field.attr 'id'}"
    (e) =>
      unless dropdown.is ':visible'
        setTimeout ->
          $(document).on event_name, (e) =>
            if $(e.target).closest(dropdown).length == 0
              $(document).off event_name
              dropdown.hide()
        , 1
      dropdown.show()
      @args.onChange @time

  selectFromMenu: (field, updateType) =>
    (e) =>
      value = $(e.target).val()
      field.val value

      if updateType == 'time'
        time = moment value, validTimeFormats
        @time.startOf('day').hours(time.hours()).minutes(time.minutes()).seconds(time.seconds())
      else
        @time.set updateType, value
        #$(e.target).parent().hide()
        #$(document).off "click.better_datetimepicker_openselectmenu_#{field.attr 'id'}"

      @buildCalendar()
      @buildMonthList()
      @buildYearList()
      @buildTimeList()
      @args.onChange @time

  enterValue: (field, updateType) =>
    (e) =>
      if e.keyCode? and e.keyCode != 13
        return

      value = $(e.target).val()

      if updateType == 'time'
        time = moment value, validTimeFormats
        if time.isValid()
          @time.startOf('day').hours(time.hours()).minutes(time.minutes()).seconds(time.seconds())
      else
        value = parseInt value
        value = Math.max yMin, value
        value = Math.min yMax, value
        @time.year value

      @buildCalendar()
      @buildMonthList()
      @buildYearList()
      @buildTimeList()
      @args.onChange @time

  registerKeyEvent: (keyCode, eventFunc) =>
    @keyEvents[keyCode] = eventFunc

  clearKeyEvents: =>
    @keyEvents = {}

  handleKeys: (e) =>
    keyCode = @args.keyPress e
    if not @keyBlocks.hasOwnProperty(keyCode) and @keyEvents.hasOwnProperty(keyCode)
      @keyEvents[keyCode] e
    else if not @keyBlocks.hasOwnProperty(keyCode) and @keyEvents.hasOwnProperty('default')
      @keyEvents.default e




################################################################################
# A reference to a particular instance of a DateTimePicker plus information    #
#   relating to that DateTimePicker.                                           #
################################################################################

class DateTimePickerRef
  args: null
  elem: null

  constructor: (@args, @elem) ->

  open: ->
    @elem.openMenu 0, 0, @args.onOpen(), @args.anchor, @args.autoClose, @args

    for key of @args.onKeys
      @elem.registerKeyEvent key, @args.onKeys[key]

    x = @args.hPosition @elem.jqObj.outerWidth(), @elem.jqObj.outerHeight()
    y = @args.vPosition @elem.jqObj.outerWidth(), @elem.jqObj.outerHeight()

    @elem.jqObj.css
      left: x
      top: y

  close: ->
    @elem.clearKeyEvents()
    @elem.closeMenu()

  @onChange: (time) ->
    @args.onChange(time)

  @onClose: (time) ->
    @args.onClose(time)
