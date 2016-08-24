$ ->
  window.helpers ?= {}
  
  ###
  Timestamp Parser
    This supports the date and time portions of http://en.wikipedia.org/wiki/ISO_8601
    except it requires a full date (cannot ommit month or day). In addition, it
    some alternate seperator characters and AM/PM which are not supported in 8601.
    
    Also supports giving a year as an integer.
  ###
  helpers.parseTimestamp = (str) ->
    if (str is null)  or (str is "")
      return null
    else if not isNaN(Number str)
      year = Number str
      d = new Date(0)
      d.setUTCFullYear(year)
      
      return [d.valueOf(), year]
    else if str.match /[ ]*[uU][ ]*(\-?\d+)/
      val = Number (str.match /[ ]*[uU][ ]*(\-?\d+)/)[1]
      d = new Date(val)
      
      return [d.valueOf(), year]
    else
      try
        ret = parseDate({}, str)
        ret = parseTime(ret[0], ret[1])
        
        d = new Date(Date.UTC ret[0].year, ret[0].month, ret[0].day,
          ret[0].hour, ret[0].minute, ret[0].second, ret[0].milisecond)
        # Make sure the year was interpretted correctly
        d.setUTCFullYear(ret[0].year)
        
        return [d.valueOf(), d.getUTCFullYear()]
      catch err
        return NaN
  
  # Acceptable seperators
  sepExp = /[ \-\+\/_T,]*/
  sepExpReq = /[ \-\+\/_T,]+/
  
  # Match a given pattern on a given string with 0 or more seperators preceeding it
  matchWithSep = (str, pat) ->
    str.match(new RegExp(sepExp.source + pat.source))
    
  # Match a given pattern on a given string with 1 or more seperators preceeding it
  matchWithSepReq = (str, pat) ->
    str.match(new RegExp(sepExpReq.source + pat.source))
    
  # Wrapper for a normal match (no seperator) for consistant syntax
  matchNoSep = (str, pat) ->
    str.match pat
  
  ###
  Parse the Date
    Requires year month and day (in that order) Year can be negative (or zero)
  ###
  parseDate = (res, str) ->
    originalStr = str;
    # Year
    ym = matchNoSep(str, /[\-\+]?\d+/)
    if ym is null
      throw new Error('fail')
      
    res.year = Number ym[0]
    str = str.substr ym[0].length
    # Month
    mm = matchWithSep(str, /(\d{1,2}|[a-zA-Z]{3})/)
    if mm is null
      throw new Error('fail')
      
    res.month = (new Date mm[1] + "/20 1970").getMonth()
    str = str.substr mm[0].length
    # Day
    dm = matchWithSep(str, /(\d+)/)
    if dm is null
      throw new Error('fail')
      
    res.day = Number dm[1]
    str = str.substr dm[0].length

    # Recalculate in American format if date is nonsense
    if res.day > 31 or isNaN(res.month)
      str = originalStr

      # Month
      mm = matchWithSep(str, /(\d{1,2}|[a-zA-Z]{3})/)
      if mm is null
        throw new Error('fail')
        
      res.month = (new Date mm[1] + "/20 1970").getMonth()
      str = str.substr mm[0].length

      # Day
      dm = matchWithSep(str, /(\d+)/)
      if dm is null
        throw new Error('fail')
        
      res.day = Number dm[1]
      str = str.substr dm[0].length

      # Year
      ym = matchNoSep(str, /[\-\+]?\d+/)
      if ym is null
        throw new Error('fail')
        
      res.year = Number ym[0]
      str = str.substr ym[0].length
  
    return [res, str]
  
  # Wrapper to call parseHour, which sets off the whole time chain
  parseTime = (res, str) ->
    ret = parseHour(res, str)
  
  ###
  Parses the hour.
    If the hour has a fractional value or is not there, skip to AM/PM test
  ###
  parseHour = (res, str) ->
    hm = matchWithSepReq(str, /(\d\d)(\.\d+)?/)
    
    if hm is null
      # no hour
      res.hour = 0
      res.minute = 0
      res.second = 0
      res.milisecond = 0
      return parseAMPM(res, str)
    
    res.hour = Number hm[1]
    str = str.substr hm[0].length
    
    if hm[2]?
      # fractional hour - jump forward
      fraction = Number(hm[2]) * 60
      res.minute = Math.floor fraction
      
      fraction = (fraction - res.minute) * 60
      res.second = Math.floor fraction
      
      fraction = (fraction - res.second) * 1000
      res.milisecond = Math.round fraction
      return parseAMPM(res, str)
      
    return parseMinute(res, str)
  
  ###
  Parses the minute.
    If the minute has a fractional value or is not there, skip to AM/PM test
  ###
  parseMinute = (res, str) ->
    mm = matchNoSep(str, /:?(\d\d)(\.\d+)?/)
    
    if mm is null
      # no minute
      res.minute = 0
      res.second = 0
      res.milisecond = 0
      return parseAMPM(res, str)
    
    res.minute = Number mm[1]
    str = str.substr mm[0].length
    
    if mm[2]?
      # fractional minute - jump forward
      fraction = Number(mm[2]) * 60
      res.second = Math.floor fraction
      
      fraction = (fraction - res.second) * 1000
      res.milisecond = Math.round fraction
      return parseAMPM(res, str)
      
    return parseSecond(res, str)
  
  ###
  Parses the Second.
  ###
  parseSecond = (res, str) ->
    sm = matchNoSep(str, /:?(\d\d)(\.\d+)?/)
    
    if sm is null
      # no second
      res.second = 0
      res.milisecond = 0
      return parseAMPM(res, str)
    
    res.second = Number sm[1]
    str = str.substr sm[0].length
    
    if sm[2]?
      # milisecond present
      res.milisecond = Math.round (Number(sm[2]) * 1000)
    else
      res.milisecond = 0
      
    return parseAMPM(res, str)
  
  ###
  Parses AM/PM
    If present, make the relevant modification to the hour
  ###
  parseAMPM = (res, str) ->
    mm = matchWithSep(str, /[aApP][mM]/)
    
    if mm isnt null
      str = str.substr mm[0].length
      if mm[0].toLowerCase() is "pm"
        res.hour = (res.hour % 12) + 12
      else # am
        res.hour = (res.hour % 12)
      
    return parseTimeZone(res, str)
  
  ###
  Parse timezone
    If present, makes the relevant minute modifications, otherwise assumes 24hr.
  ###
  parseTimeZone = (res, str) ->
    if matchWithSep(str, /[zZ]/) is null
      tm = matchWithSep(str, /([\+\-]\d\d):?(\d\d)?/)
      
      if tm isnt null
        adj = Number(tm[1]) * 60
        if tm[2]?
          mul = if adj < 0 then -1 else 1
          adj += Number(tm[2]) * mul
          
        res.minute -= adj
      
    return [res, str]
      
      
