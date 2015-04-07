class RefactorInvisibleFields < ActiveRecord::Migration
  # When adding or removing invisible fields, such as group options,
  # appropriately increment or decrement the number 'n'.  It represents
  # the amount of invisible fields - 1.  Also be sure to adjust
  # the name, unit, and type for your new hidden field.  This
  # information can all be found by looking at the 'data' JSON
  # dump of a saved visualization that includes your hidden field.
  n = 2
  name = "Contributors"
  unit = "String"
  type = 3
  hash_name = "CONTRIBUTOR_FIELD"

  def change
    say 'Adding new virtual field to projects and saved vises'

    Project.find_each do | p |
      # projects require a globals update
      globals = JSON.parse(p.globals)

      # update everything field related
      globals = refactor_globals(globals)

      # save the new globals
      p.globals = JSON.dump(globals)
      p.save
    end

    Visualization.find_each do | v |
      # vises require a globals and data update
      globals = JSON.parse(v.globals)
      data = JSON.parse(v.data)

      # update everything field related
      globals = refactor_globals(globals)
      data = refactor_data(data)

      # save the new globals and data
      v.globals = JSON.dump(globals)
      v.data = JSON.dump(data)
      v.save
    end
  end

  def refactor_globals(globals)
    # global
    subglobal = globals['global']
    if subglobal['groupById'] >= n
      subglobal['groupById'] += 1
    end
    if subglobal['fieldSelection'] >= n
      subglobal['fieldSelection'] += 1
    end

    # map unaffected

    # timeline
    timeline = globals['Timeline']
    if timeline['xAxis'] >= n
      timeline['xAxis'] += 1
    end
    timeline['yAxis'].each_with_index do | y, i |
      if y >= n
        timeline['yAxis'][i] += 1
      end
    end
    timeline['savedRegressions'].each do | regres |
      if regres['xAxis'] >= n
        regres['xAxis'] += 1
      end
      if regres['yAxis'] >= n
        regres['yAxis'] += 1
      end
    end

    # scatter
    scatter = globals['Scatter']
    if scatter['xAxis'] >= n
      scatter['xAxis'] += 1
    end
    scatter['yAxis'].each_with_index do | y, i |
      if y >= n
        scatter['yAxis'][i] += 1
      end
    end
    scatter['savedRegressions'].each do | regres |
      if scatter['xAxis'] >= n
        scatter['xAxis'] += 1
      end
      if regres['yAxis'] >= n
        regres['yAxis'] += 1
      end
    end

    # bar
    bar = globals['Bar']
    if bar['sortField'] >= n
      bar['sortField'] += 1
    end

    # histogram
    histogram = globals['Histogram']
    if histogram['displayField'] >= n
      histogram['displayField'] += 1
    end

    # pie
    pie = globals['Pie']
    if pie['displayField'] >= n
      pie['displayField'] += 1
    end

    # table
    table = globals['Table']
    table['tableFields'].each_with_index do | t, i |
      if t >= n
        table['tableFields'][i] += 1
      end
    end
    table['tableFields'].push(n)
    table['tableFields'].sort!

    # summary
    summary = globals['Summary']
    if summary['displayField'] >= n
      summary['displayField'] += 1
    end

    # photos unaffected

    globals
  end

  def refactor_data(data)
    # add the new hidden field
    fields = data['fields']
    new_field = Hash.new
    new_field['typeID'] = type
    new_field['unitName'] = unit
    new_field['fieldID'] = -1
    new_field['fieldName'] = name
    fields.insert(n + 1, new_field)

    ### TODO - how are we going to get contrib field
    ###        in here?  (e.g. Key: a, User: Timmy)
    ###        For now, pushing ""
    dp = data['dataPoints']
    dp.each_with_index do | d, i |
      dp[i].insert(n + 1, "")
    end

    # add to the data hash the new hidden field index
    data[hash_name] = n + 1

    # update field arrays
    text_f = data['textFields']
    text_f.each_width_index do | t, i |
      if t >= n
        text_f[i] += 1
      end
    end
    text_f.push(n)
    text_f.sort!

    time_f = data['timeFields']
    time_f.each_width_index do | t, i |
      if t >= n
        time_f[i] += 1
      end
    end

    norm_f = data['normalFields']
    norm_f.each_width_index do | t, i |
      if t >= n
        norm_f[i] += 1
      end
    end

    num_f = data['numericFields']
    num_f.each_width_index do | t, i |
      if t >= n
        num_f[i] += 1
      end
    end

    geo_f = data['normalFields']
    geo_f.each_width_index do | t, i |
      if t >= n
        geo_f[i] += 1
      end
    end

    # add the hidden field to group selection
    data['groupSelection'].push(n)

    data
  end
end
