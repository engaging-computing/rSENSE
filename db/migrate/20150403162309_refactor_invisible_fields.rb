class RefactorInvisibleFields < ActiveRecord::Migration
  # When adding or removing invisible fields, such as group options,
  # appropriately increment or decrement the number 'n'.  It represents
  # the amount of invisible fields - 1.  Also be sure to adjust
  # the name, unit, and type for your new hidden field.  This
  # information can all be found by looking at the 'data' JSON
  # dump of a saved visualization that includes your hidden field.
  class Param
    def self.n
      2
    end
    def self.name
      'Contributors'
    end
    def self.unit
      'String'
    end
    def self.type
      3
    end
    def self.hash_name
      'CONTRIBUTOR_FIELD'
    end
  end

  # Run the migration up (rake db:migrate)
  def up
    refactor(1)
  end

  # Run the migration down (rake db:rollback)
  def down
    refactor(-1)
  end

  def refactor(dir)
    if dir > 0
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

  def refactor_scatter(scatter, dir)
    if scatter.nil?
      nil
    else
      if !scatter['xAxis'].nil? && scatter['xAxis'] >= Param.n
        scatter['xAxis'] += dir
      end
      unless scatter['yAxis'].nil?
        scatter['yAxis'].each_with_index do | y, i |
          if y >= Param.n
            scatter['yAxis'][i] += dir
          end
        end
      end
      unless scatter['savedRegressions'].nil?
        scatter['savedRegressions'].each do | regres |
          if !regres['xAxis'].nil? && regres['xAxis'] >= Param.n
            regres['xAxis'] += dir
          end
          if !regres['yAxis'].nil? && regres['yAxis'] >= Param.n
            regres['yAxis'] += dir
          end
        end
      end
      scatter
    end
  end

  def refactor_table(table, dir)
    if table.nil? || table['tableFields'].nil?
      nil
    else
      table['tableFields'].each_with_index do | t, i |
        if t >= Param.n
          table['tableFields'][i] += dir
        end
      end
      if dir > 0
        table['tableFields'].push(Param.n)
      else
        table['tableFields'] -= [Param.n]
      end
      table['tableFields'].sort!
      table
    end
  end

  def refactor_globals(globals, dir)
    # global
    subglobals = globals['globals']
    unless subglobals.nil?
      if subglobals['groupById'] >= Param.n
        subglobals['groupById'] += dir
      end
      subglobals['fieldSelection'].each_with_index do | f, i |
        if f >= Param.n
          subglobals['fieldSelection'][i] += dir
        end
      end
      globals['globals'] = subglobals
    end

    # map
    map = globals['Map']
    unless map.nil?
      if !map['heatmapSelection'].nil? && map['heatmapSelection'] >= Param.n
        map['heatmapSelection'] += dir
      end
      globals['Map'] = map
    end

    # timeline
    timeline = refactor_scatter(globals['Timeline'], dir)
    unless timeline.nil?
      globals['Timeline'] = timeline
    end

    # scatter
    scatter = refactor_scatter(globals['Scatter'], dir)
    unless scatter.nil?
      globals['Scatter'] = scatter
    end

    # bar unaffected: axis uses the globals.fieldSelection
    # histogram unaffected: axis uses the globals.fieldSelection

    # pie
    pie = globals['Pie']
    unless pie.nil?
      if !pie['displayField'].nil? && pie['displayField'] >= Param.n
        pie['displayField'] += dir
      end
      globals['Pie'] = pie
    end

    # table
    table = refactor_table(globals['Table'], dir)
    unless table.nil?
      globals['Table'] = table
    end

    # summary
    summary = globals['Summary']
    unless summary.nil?
      if !summary['displayField'].nil? && summary['displayField'] >= Param.n
        summary['displayField'] += dir
      end
      globals['Summary'] = summary
    end

    globals
  end

  def refactor_data(data, dir)
    # add the new hidden field, or remove if direction is down
    fields = data['fields']
    unless fields.nil?
      if dir > 0
        new_field = {}
        new_field['typeID'] = Param.type
        new_field['unitName'] = Param.unit
        new_field['fieldID'] = -1
        new_field['fieldName'] = Param.name
        fields.insert(Param.n + 1, new_field)
      else
        fields.delete_at(Param.n + 1)
      end
      data['fields'] = fields
    end

    # insert a blank string as the hidden field for this object;
    # doing so makes this migration modular and applicable to
    # future uses of this migration when adding more hidden fields
    dp = data['dataPoints']
    unless dp.nil?
      dp.each_with_index do | d, i |
        if dir > 0
          dp[i].insert(Param.n + 1, '""')
        else
          dp[i].delete_at(Param.n + 1)
        end
      end
      data['dataPoints'] = dp
    end

    # add to the data hash the new hidden field index, or remove
    # if the direction is down
    if dir > 0
      data[Param.hash_name] = Param.n + 1
    else
      data.delete(Param.hash_name)
    end

    # update field arrays
    text_f = data['textFields']
    unless text_f.nil?
      text_f.each_with_index do | t, i |
        if t >= Param.n
          text_f[i] += dir
        end
      end
      if dir > 0
        # add the new field to the array
        text_f.push(Param.n)
      else
        # remove the new field from the array
        text_f -= [Param.n]
      end
      text_f.sort!
      data['textFields'] = text_f
    end

    time_f = data['timeFields']
    unless time_f.nil?
      time_f.each_with_index do | t, i |
        if t >= Param.n
          time_f[i] += dir
        end
      end
      data['timeFields'] = time_f
    end

    norm_f = data['normalFields']
    unless norm_f.nil?
      norm_f.each_with_index do | t, i |
        if t >= Param.n
          norm_f[i] += dir
        end
      end
      data['normalFields'] = norm_f
    end

    num_f = data['numericFields']
    unless num_f.nil?
      num_f.each_with_index do | t, i |
        if t >= Param.n
          num_f[i] += dir
        end
      end
      data['numericFields'] = num_f
    end

    geo_f = data['geoFields']
    unless geo_f.nil?
      geo_f.each_with_index do | t, i |
        if t >= Param.n
          geo_f[i] += dir
        end
      end
      data['geoFields'] = geo_f
    end

    # add the hidden field to group selection, or remove
    # if direction is down
    if dir > 0
      data['groupSelection'].push(Param.n)
    else
      data['groupSelection'] -= [Param.n]
    end

    data
  end
end
