###
  * Copyright (c) 2011, iSENSE Project. All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
  * modification, are permitted provided that the following conditions are met:
  *
  * Redistributions of source code must retain the above copyright notice, this
  * list of conditions and the following disclaimer. Redistributions in binary
  * form must reproduce the above copyright notice, this list of conditions and
  * the following disclaimer in the documentation and/or other materials
  * provided with the distribution. Neither the name of the University of
  * Massachusetts Lowell nor the names of its contributors may be used to
  * endorse or promote products derived from this software without specific
  * prior written permission.
  *
  * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
  * ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR
  * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
  * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
  * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
  * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
  * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
  * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
  * DAMAGE.
  *
###
$ ->
  if namespace.controller is 'visualizations' and
  namespace.action in ['displayVis', 'embedVis', 'show']
    ###
    Clears filters in the current UI
    ###
    window.clearFilters = ->
      $('.vis-filter').remove()

    ###
    Adds a filter to the current UI
    ###
    window.addFilter = (f) ->
      f.fieldName = fieldTitle(data.fields[f.field])
      f.opName    = globals.filterNames[f.op]

      formatter =
        if f.field is data.timeFields[0] then globals.dateFormatter
        else data.precisionFilter

      if f.value?
        f.dispValue  = formatter(f.value)
      else
        delimiter = ', '
        switch f.op
          when 'bb'
            opener = '['
            closer = ']'
          when 'bt'
            opener = '('
            closer = ')'
          else
            opener = '('
            closer = ')'

        f.dispValue = opener
        if f.lvalue? then f.dispValue += data.precisionFilter(f.lvalue)
        f.dispValue += delimiter
        if f.uvalue? then f.dispValue += data.precisionFilter(f.uvalue)
        f.dispValue += closer

      filterBox = HandlebarsTemplates[hbVis('vis-filter')](f)
      $('#vis-filters').append(filterBox)

    window.globals ?= {}

    ###
    Numerical Filters
      v    the value you are comparing against
      i    the index of the field you are comparing

      returns a function that can be used to filter a data array
    ###
    # Less than
    globals.lt = (v, i) ->
      (a) ->
        unless a[i]? then return false
        return Number(a[i]) < Number(v)

    # Greater than
    globals.gt = (v, i) ->
      (a) ->
        unless a[i]? then return false
        return Number(a[i]) > Number(v)

    # Less than or equal to
    globals.le = (v, i) ->
      (a) ->
        unless a[i]? then return false
        return Number(a[i]) <= Number(v)

    # Greater than or equal to
    globals.ge = (v, i) ->
      (a) ->
        unless a[i]? then return false
        return Number(a[i]) >= Number(v)

    # Equal to
    globals.eq = (v, i) ->
      (a) ->
        unless a[i]? then return false
        return Number(a[i]) == Number(v)

    # Not equal to
    globals.ne = (v, i) ->
      (a) ->
        unless a[i]? then return false
        return Number(a[i]) != Number(v)

    ###
    Radial Filters
      min  lower bound of the radial measure
      max  upper bound of the radial measure
      lv   lower value you are comparing against
      uv   upper value you are comparing against
      i    the index of the field you are comparing

      returns a function that can be used to filter a data array
    ###
    # Between (exclusive)
    globals.bt = (min, max, lv, uv, i) ->
      (a) ->
        unless a[i]? then return false
        val = Number(a[i])
        lwr = Number(lv)
        upr = Number(uv)
        if lwr > upr
          offset = Number(max) - Number(min)
          upr += offset
          if val < lwr then val += offset

        return val > lwr && val < upr

    # Bounded by (inclusive between)
    globals.bb = (min, max, lv, uv, i) ->
      (a) ->
        unless a[i]? then return false
        val = Number(a[i])
        lwr = Number(lv)
        upr = Number(uv)
        if lwr > upr
          offset = Number(max) - Number(min)
          upr += offset
          if val < lwr then val += offset

        return val >= lwr && val <= upr

    ###
    String Filters
      s is the value you are comparing against
      i is the index of the field you are comparing

      returns a function that can be used to filter a data array
    ###
    # String matching support for older browsers
    # http://stackoverflow.com/questions/646628/
    #   how-to-check-if-a-string-startswith-another-string
    if (typeof String.prototype.startsWith != 'function')
      String.prototype.startsWith = (str) ->
        this.slice(0, str.length) is str

    if (typeof String.prototype.endsWith != 'function')
      String.prototype.endsWith = (str) ->
        this.slice(-str.length) is str

    if (typeof String.prototype.contains != 'function')
      String.prototype.contains = (str) ->
        this.indexOf(str) isnt -1

    # Begins with
    globals.bw = (s, i) ->
      (a) -> String(a[i]).startsWith(String(s))

    # Does not begin with
    globals.bn = (s, i) ->
      (a) -> not String(a[i]).startsWith(String(s))

    # Is in
    globals.in = (s, i) ->
      (a) -> String(s).contains(String(a[i]))

    # Is not in
    globals.ni = (s, i) ->
      (a) -> not String(s).contains(String(a[i]))

    # Ends with
    globals.ew = (s, i) ->
      (a) -> String(a[i]).endsWith(String(s))

    # Does not end with
    globals.en = (s, i) ->
      (a) -> not String(a[i]).endsWith(String(s))

    # Contains
    globals.cn = (s, i) ->
      (a) -> String(a[i]).contains(String(s))

    # Does not contain
    globals.nc = (s, i) ->
      (a) -> not String(a[i]).contains(String(s))

    # Filter names
    globals.filterNames =
      lt: '<'
      le: '< or ='
      gt: '>'
      ge: '> or ='
      eq: '='
      ne: 'not ='
      bt: 'between'
      bb: 'bounded by'
      bw: 'begins with'
      bn: 'doesn\'t begin with'
      in: 'is in'
      ni: 'isn\'t in'
      ew: 'ends with'
      en: 'doesn\'t end with'
      cn: 'contains'
      nc: 'doesn\'t contain'
