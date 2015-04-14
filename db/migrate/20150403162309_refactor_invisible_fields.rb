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

  def up
    refactor(1)
  end

  def down
    refactor(-1)
  end

  def refactor(dir)
    say 'Adding new virtual field to projects and saved vises'

    Project.find_each do | p |
      # projects require a globals update
      globals = JSON.parse(p.globals)

      # update everything field related
      globals = refactor_globals(globals, dir)

      # save the new globals
      p.globals = JSON.dump(globals)
      p.save
    end

    Visualization.find_each do | v |
      # vises require a globals and data update
      globals = JSON.parse(v.globals)
      data = JSON.parse(v.data)

      # update everything field related
      globals = refactor_globals(globals, dir)
      data = refactor_data(data, dir)

      # save the new globals and data
      v.globals = JSON.dump(globals)
      v.data = JSON.dump(data)
      v.save
    end
  end

  def refactor_globals(globals, dir)
    # global
    subglobal = globals['global']
    if subglobal['groupById'] >= n
      subglobal['groupById'] += dir
    end
    if subglobal['fieldSelection'] >= n
      subglobal['fieldSelection'] += dir
    end

    # map unaffected

    # timeline
    timeline = globals['Timeline']
    if timeline['xAxis'] >= n
      timeline['xAxis'] += dir
    end
    timeline['yAxis'].each_with_index do | y, i |
      if y >= n
        timeline['yAxis'][i] += dir
      end
    end
    timeline['savedRegressions'].each do | regres |
      if regres['xAxis'] >= n
        regres['xAxis'] += dir
      end
      if regres['yAxis'] >= n
        regres['yAxis'] += dir
      end
    end

    # scatter
    scatter = globals['Scatter']
    if scatter['xAxis'] >= n
      scatter['xAxis'] += dir
    end
    scatter['yAxis'].each_with_index do | y, i |
      if y >= n
        scatter['yAxis'][i] += dir
      end
    end
    scatter['savedRegressions'].each do | regres |
      if scatter['xAxis'] >= n
        scatter['xAxis'] += dir
      end
      if regres['yAxis'] >= n
        regres['yAxis'] += dir
      end
    end

    # bar
    bar = globals['Bar']
    if bar['sortField'] >= n
      bar['sortField'] += dir
    end

    # histogram
    histogram = globals['Histogram']
    if histogram['displayField'] >= n
      histogram['displayField'] += dir
    end

    # pie
    pie = globals['Pie']
    if pie['displayField'] >= n
      pie['displayField'] += dir
    end

    # table
    table = globals['Table']
    table['tableFields'].each_with_index do | t, i |
      if t >= n
        table['tableFields'][i] += dir
      end
    end
    table['tableFields'].push(n)
    table['tableFields'].sort!

    # summary
    summary = globals['Summary']
    if summary['displayField'] >= n
      summary['displayField'] += dir
    end

    # photos unaffected

    globals
  end

  def refactor_data(data, dir)
    # add the new hidden field, or remove if direction is down
    fields = data['fields']
    if (dir > 0)
      new_field = Hash.new
      new_field['typeID'] = type
      new_field['unitName'] = unit
      new_field['fieldID'] = -1
      new_field['fieldName'] = name
      fields.insert(n + 1, new_field)
    else
      fields.delete_at(n + 1)

    # insert a blank string as the hidden field for this object;
    # doing so makes this migration modular and applicable to
    # future uses of this migration when adding more hidden fields
    dp = data['dataPoints']
    dp.each_with_index do | d, i |
      if (dir > 0)
        dp[i].insert(n + 1, "")
      else
        dp[i].delete_at(n + 1)
      end
    end

    # add to the data hash the new hidden field index, or remove
    # if the direction is down
    if (dir > 0)
      data[hash_name] = n + 1
    else
      data.delete(hash_name)
    end

    # update field arrays
    text_f = data['textFields']
    text_f.each_width_index do | t, i |
      if t >= n
        text_f[i] += dir
      end
    end
    if (dir > 0)
      # add the new field to the array
      text_f.push(n)
    else
      # remove the new field from the array
      text_f -= [n]
    end
    text_f.sort!

    time_f = data['timeFields']
    time_f.each_width_index do | t, i |
      if t >= n
        time_f[i] += dir
      end
    end

    norm_f = data['normalFields']
    norm_f.each_width_index do | t, i |
      if t >= n
        norm_f[i] += dir
      end
    end

    num_f = data['numericFields']
    num_f.each_width_index do | t, i |
      if t >= n
        num_f[i] += dir
      end
    end

    geo_f = data['normalFields']
    geo_f.each_width_index do | t, i |
      if t >= n
        geo_f[i] += dir
      end
    end

    # add the hidden field to group selection, or remove
    # if direction is down
    if (dir > 0)
      data['groupSelection'].push(n)
    else
      data['groupSelection'] -= [n]
    end

    data
  end
end
