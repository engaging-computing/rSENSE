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
      if f.op is 'up'
        f.fieldName = ""
      else
        f.fieldName = fieldTitle(data.fields[f.field])
      f.opName    = globals.filterNames[f.op]
      formatter =
        if f.field is data.timeFields[0] \
        and ((f.op is 'gt') or (f.op is 'lt') or (f.op is 'ge') or (f.op is 'le'))
          globals.dateFormatter
        else if (f.field in data.textFields) \
        or f.field is data.timeFields[0]
          (str) ->
            return str
        else
          data.precisionFilter

      if f.value?
        f.dispValue = formatter(f.value)
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
        if f.lvalue? then f.dispValue += formatter(f.lvalue)
        f.dispValue += delimiter
        if f.uvalue? then f.dispValue += formatter(f.uvalue)
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
      (a) -> String(a[i]).toLowerCase().startsWith(String(s).toLowerCase())

    # Does not begin with
    globals.bn = (s, i) ->
      (a) -> not String(a[i]).toLowerCase().startsWith(String(s).toLowerCase())

    # Is in
    globals.in = (s, i) ->
      (a) -> String(s).toLowerCase().contains(String(a[i]).toLowerCase())

    # Is not in
    globals.ni = (s, i) ->
      (a) -> not String(s).toLowerCase().contains(String(a[i]).toLowerCase())

    # Ends with
    globals.ew = (s, i) ->
      (a) -> String(a[i]).toLowerCase().endsWith(String(s).toLowerCase())

    # Does not end with
    globals.en = (s, i) ->
      (a) -> not String(a[i]).toLowerCase().endsWith(String(s).toLowerCase())

    # Contains
    globals.cn = (s, i) ->
      (a) -> String(a[i]).toLowerCase().contains(String(s).toLowerCase())

    # Does not contain
    globals.nc = (s, i) ->
      (a) -> not String(a[i]).toLowerCase().contains(String(s).toLowerCase())

    # In uploading range
    globals.up = (s, i) ->
      (a) ->
        # Get dates to compare
        dset_id = globals.getDataSetId(a[data.DATASET_NAME_FIELD])
        for idx, meta of data.metadata
          if meta.dataset_id is parseInt(dset_id)
            uploaded = new Date(meta.timecreated)
            break
        now = new Date(Date.now())
        yesterday = new Date(Date.now())
        yesterday.setDate(now.getDate() - 1)
        beginning_of_week = new Date(Date.now())
        beginning_of_week.setDate(now.getDate() - now.getDay())

        # Compare
        switch s
          when 'today'
            uploaded.getFullYear() is now.getFullYear() and \
            uploaded.getMonth() is now.getMonth() and \
            uploaded.getDate() is now.getDate()
          when 'yesterday'
            uploaded.getFullYear() is now.getFullYear() and \
            uploaded.getMonth() is now.getMonth() and \
            uploaded.getDate() is yesterday.getDate()
          when 'this week'
            uploaded >= beginning_of_week
          when 'this month'
            uploaded.getFullYear() is now.getFullYear() and \
            uploaded.getMonth() is now.getMonth()
          when 'this year'
            uploaded.getFullYear() is now.getFullYear()

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
      up: 'Uploaded'
