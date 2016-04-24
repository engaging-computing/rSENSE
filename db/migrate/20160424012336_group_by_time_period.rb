# This migration is very similar to the last one because it doing the
# same thing, adding another group by field. 
class GroupByTimePeriod < ActiveRecord::Migration

  class TimeField
    def self.typeID
      3
    end
    def self.unitName
      'String'
    end
    def self.fieldID
      -1
    end
    def self.fieldName
      'Time Period'
    end
  end

  def up
    say 'adding time period field to saved vises'
    add_or_remove_field(1, 5, TimeField)
  end

  def down
    say 'removing group by time period field from saved vises'
    add_or_remove_field(-1, 5)
  end

  # 1 for up, -1 for down, position of field being added or removed, field (if field is being added)
  def add_or_remove_field(direction, position, field = nil)
    # Refactor globals for default projects to account for new group by field
    Project.find_each do | p |
      next if p.globals.nil?

      # projects require a globals update
      globals = JSON.parse(p.globals)

      # update everything field related
      globals = refactor_globals(globals, direction, position)

      # save the new globals
      p.globals = JSON.dump(globals)
      p.save
    end
 
    # Add field to saved visualization
    Visualization.find_each do | v |
      globals = v.globals.nil? ? nil : JSON.parse(v.globals)
      data = (v.data.nil? or v.data == 'null') ? nil : JSON.parse(v.data)

      # update everything field related
      unless globals.nil?
        globals = refactor_globals(globals, direction, position)
        v.globals = JSON.dump(globals)
      end
      unless data.nil?
        v.data = JSON.dump(refactor_data(data, direction, position, field))
      end

      # save the new globals and data
      v.save
    end
  end

  # If direction is up, must pass a field, and position to insert it
  # If direction is down, pass the position of the field to remove
  def refactor_data(data, direction, position, field = nil)
    fields = data['fields']
    unless fields.nil?
      if direction == 1
        new_field = {}
        new_field['typeID'] = field.typeID
        new_field['unitName'] = field.unitName
        new_field['fieldID'] = field.fieldID
        new_field['fieldName'] = field.fieldName
        fields.insert(position, new_field)
      else
        fields.delete_at(position)
      end
      data['fields'] = fields
    end

    dp = data['dataPoints']
    unless dp.nil? or dp.length == 0
      dp.each_with_index do | d, i |
        if direction == 1 # up migration
          dp[i].insert(position, '')
        else # down migration
          dp[i].delete_at(position)
        end
      end
      data['dataPoints'] = dp

      text_fields = data['textFields']
      unless text_fields.nil? or text_fields.length == 0
        text_fields.each_with_index do | f, i |
          # if greater than position, add 1 because it was shifted over
          if f >= position
            text_fields[i] += direction
          end
        end
        text_fields.push(position)
        text_fields.sort!
      end
      data['textFields'] = text_fields

      time_fields = data['timeFields']
      unless time_fields.nil? or time_fields.length == 0
        time_fields.each_with_index do | f, i |
          # if greater than position, add 1 because it was shifted over
          if f >= position
            time_fields[i] += direction
          end
        end
      end
      data['timeFields'] = time_fields

      numeric_fields = data['numericFields']
      unless numeric_fields.nil? or numeric_fields.length == 0
        numeric_fields.each_with_index do | f, i |
          # if greater than position, add 1 because it was shifted over
          if f >= position
            numeric_fields[i] += direction
          end
        end
      end
      data['numericFields'] = numeric_fields

      geo_fields = data['geoFields']
      unless geo_fields.nil? or geo_fields.length == 0
        geo_fields.each_with_index do | f, i |
          # if greater than position, add 1 because it was shifted over
          if f >= position
            geo_fields[i] += direction
          end
        end
      end
      data['geoFields'] = geo_fields

      normal_fields = data['normalFields']
      unless normal_fields.nil? or normal_fields.length == 0
        normal_fields.each_with_index do | f, i |
          # if greater than position, add 1 because it was shifted over
          if f >= position
            normal_fields[i] += direction
          end
        end
      end
      data['normalFields'] = normal_fields

    end
    data
  end

  def refactor_globals(globals, direction, position)
    # move index of fields up or down after field being added or removed

    # global
    subglobals = globals['globals']
    unless subglobals.nil?
      if subglobals['groupById'] >= position
        subglobals['groupById'] += direction
      end
      subglobals['fieldSelection'].each_with_index do | f, i |
        if f >= position
          subglobals['fieldSelection'][i] += direction
        end
      end
      globals['globals'] = subglobals
    end

    # map
    map = globals['Map']
    unless map.nil?
      if !map['heatmapSelection'].nil? && map['heatmapSelection'] >= position
        map['heatmapSelection'] += direction
      end
      globals['Map'] = map
    end

    # timeline
    timeline = refactor_scatter(globals['Timeline'], direction, position)
    unless timeline.nil?
      globals['Timeline'] = timeline
    end

    # scatter
    scatter = refactor_scatter(globals['Scatter'], direction, position)
    unless scatter.nil?
      globals['Scatter'] = scatter
    end

    # bar
    bar = globals['Bar']
    unless bar.nil?
      if !bar['sortField'].nil? && bar['sortField'] >= position
        bar['sortField'] += direction
      end
      globals['Bar'] = bar
    end

    # histogram unaffected: axis uses the globals.fieldSelection

    # pie
    pie = globals['Pie']
    unless pie.nil?
      if !pie['displayField'].nil? && pie['displayField'] >= position
        pie['displayField'] += direction
      end
      globals['Pie'] = pie
    end

    # table
    table = refactor_table(globals['Table'], direction, position)
    unless table.nil?
      globals['Table'] = table
    end

    # summary
    summary = globals['Summary']
    unless summary.nil?
      if !summary['displayField'].nil? && summary['displayField'] >= position
        summary['displayField'] += direction
      end
      globals['Summary'] = summary
    end

    globals
  end

  def refactor_scatter(scatter, direction, position)
    if scatter.nil?
      nil
    else
      if !scatter['xAxis'].nil? && scatter['xAxis'] >= position
        scatter['xAxis'] += direction
      end
      unless scatter['yAxis'].nil?
        scatter['yAxis'].each_with_index do | y, i |
          if y >= position
            scatter['yAxis'][i] += direction
          end
        end
      end
      unless scatter['savedRegressions'].nil?
        scatter['savedRegressions'].each do | regres |
          if !regres['xAxis'].nil? && regres['xAxis'] >= position
            regres['xAxis'] += direction
          end
          if !regres['yAxis'].nil? && regres['yAxis'] >= position
            regres['yAxis'] += direction
          end
        end
      end
      scatter
    end
  end

  def refactor_table(table, direction, position)
    if table.nil? || table['tableFields'].nil?
      nil
    else
      table['tableFields'].each_with_index do | t, i |
        if t >= position
          table['tableFields'][i] += direction
        end
      end
      # if position is 3 then it is the number group by field and we do not want that on the table
      if direction == 1 && position != 3
        table['tableFields'].push(position)
      elsif position != 3
        table['tableFields'] -= [position]
      end
      table['tableFields'].sort!
      table
    end
  end
end
