class RefactorInvisibleFields < ActiveRecord::Migration
  # When adding or removing invisible fields, such as group options,
  # appropriately increment or decrement the number 'n'.  It represents
  # the amount of invisible fields - 1.  Also be sure to adjust
  # the name, unit, and type for your new hidden field.  This
  # information can all be found by looking at the 'data' JSON
  # dump of a saved visualization that includes your hidden field.
  $n = 2
  $name = "Contributors"
  $unit = "String"
  $type = 3
  $hash_name = "CONTRIBUTOR_FIELD"

  def up
    refactor(1)
  end

  def down
    refactor(-1)
  end

  def refactor(dir)
    if (dir > 0)
      say 'Adding new virtual field to projects and saved vises'
    else
      say 'Removing virtual field from projects and saved vises'
    end

    Project.find_each do | p |
      next if p.globals.nil?

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
      globals = v.globals.nil? ? nil : JSON.parse(v.globals)
      data = v.data.nil? ? nil : JSON.parse(v.data)

      # update everything field related
      unless globals.nil?
        globals = refactor_globals(globals, dir)
        v.globals = JSON.dump(globals)
      end
      unless data.nil?
        data = refactor_data(data, dir)
        v.data = JSON.dump(data)
      end

      # save the new globals and data
      v.save
    end
  end

  def refactor_globals(globals, dir)
    # global
    subglobal = globals['global']
    unless subglobal.nil?
      if subglobal['groupById'] >= $n
        subglobal['groupById'] += dir
      end
      if subglobal['fieldSelection'] >= $n
        subglobal['fieldSelection'] += dir
      end
    end

    # map unaffected

    # timeline
    timeline = globals['Timeline']
    unless timeline.nil?
      if !timeline['xAxis'].nil? && timeline['xAxis'] >= $n
        timeline['xAxis'] += dir
      end
      unless timeline['yAxis'].nil?
        timeline['yAxis'].each_with_index do | y, i |
          if y >= $n
            timeline['yAxis'][i] += dir
          end
        end
      end
      unless timeline['savedRegressions'].nil?
        timeline['savedRegressions'].each do | regres |
          if !regres['xAxis'].nil? && regres['xAxis'] >= $n
            regres['xAxis'] += dir
          end
          if !regres['yAxis'].nil? && regres['yAxis'] >= $n
            regres['yAxis'] += dir
          end
        end
      end
    end

    # scatter
    scatter = globals['Scatter']
    unless scatter.nil?
      if !scatter['xAxis'].nil? && scatter['xAxis'] >= $n
        scatter['xAxis'] += dir
      end
      unless scatter['yAxis'].nil?
        scatter['yAxis'].each_with_index do | y, i |
          if y >= $n
            scatter['yAxis'][i] += dir
          end
        end
      end
      unless scatter['savedRegressions'].nil?
        scatter['savedRegressions'].each do | regres |
          if !regres['xAxis'].nil? && regres['xAxis'] >= $n
            regres['xAxis'] += dir
          end
          if !regres['yAxis'].nil? && regres['yAxis'] >= $n
            regres['yAxis'] += dir
          end
        end
      end
    end

    # bar
    bar = globals['Bar']
    unless bar.nil?
      if !bar['sortField'].nil? && bar['sortField'] >= $n
        bar['sortField'] += dir
      end
    end

    # histogram
    histogram = globals['Histogram']
    unless histogram.nil?
      if !histogram['displayField'].nil? && histogram['displayField'] >= $n
        histogram['displayField'] += dir
      end
    end

    # pie
    pie = globals['Pie']
    unless pie.nil?
      if !pie['displayField'].nil? && pie['displayField'] >= $n
        pie['displayField'] += dir
      end
    end

    # table
    table = globals['Table']
    unless table.nil? || table['tableFields'].nil?
      table['tableFields'].each_with_index do | t, i |
        if t >= $n
          table['tableFields'][i] += dir
        end
      end
      if (dir > 0)
        table['tableFields'].push($n)
      else
        table['tableFields'] -= [$n]
      end
      table['tableFields'].sort!
    end

    # summary
    summary = globals['Summary']
    unless summary.nil?
      if !summary['displayField'].nil? && summary['displayField'] >= $n
        summary['displayField'] += dir
      end
    end

    # photos unaffected

    globals
  end

  def refactor_data(data, dir)
    # add the new hidden field, or remove if direction is down
    fields = data['fields']
    unless fields.nil?
      if (dir > 0)
        new_field = Hash.new
        new_field['typeID'] = $type
        new_field['unitName'] = $unit
        new_field['fieldID'] = -1
        new_field['fieldName'] = $name
        fields.insert($n + 1, new_field)
      else
        fields.delete_at($n + 1)
      end
    end

    # insert a blank string as the hidden field for this object;
    # doing so makes this migration modular and applicable to
    # future uses of this migration when adding more hidden fields
    dp = data['dataPoints']
    unless dp.nil?
      dp.each_with_index do | d, i |
        if (dir > 0)
          dp[i].insert($n + 1, "")
        else
          dp[i].delete_at($n + 1)
        end
      end
    end

    # add to the data hash the new hidden field index, or remove
    # if the direction is down
    if (dir > 0)
      data[$hash_name] = $n + 1
    else
      data.delete($hash_name)
    end

    # update field arrays
    text_f = data['textFields']
    unless text_f.nil?
      text_f.each_with_index do | t, i |
        if t >= $n
          text_f[i] += dir
        end
      end
      if (dir > 0)
        # add the new field to the array
        text_f.push($n)
      else
        # remove the new field from the array
        text_f -= [$n]
      end
      text_f.sort!
    end

    time_f = data['timeFields']
    unless time_f.nil?
      time_f.each_with_index do | t, i |
        if t >= $n
          time_f[i] += dir
        end
      end
    end

    norm_f = data['normalFields']
    unless norm_f.nil?
      norm_f.each_with_index do | t, i |
        if t >= $n
          norm_f[i] += dir
        end
      end
    end

    num_f = data['numericFields']
    unless num_f.nil?
      num_f.each_with_index do | t, i |
        if t >= $n
          num_f[i] += dir
        end
      end
    end

    geo_f = data['normalFields']
    unless geo_f.nil?
      geo_f.each_with_index do | t, i |
        if t >= $n
          geo_f[i] += dir
        end
      end
    end

    # add the hidden field to group selection, or remove
    # if direction is down
    if (dir > 0)
      data['groupSelection'].push($n)
    else
      data['groupSelection'] -= [$n]
    end

    data
  end
end
