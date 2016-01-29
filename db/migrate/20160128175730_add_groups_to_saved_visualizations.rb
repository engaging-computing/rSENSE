class AddGroupsToSavedVisualizations < ActiveRecord::Migration

  class Number_Field
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
      'Number Fields'
    end
  end

   class Contributor_Field
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
      'Contributors'
    end
  end

  def up
    add_field('up', 3, Number_Field)
    add_field('up', 4, Contributor_Field)
  end

  def down
    add_field('down', 4)
    add_field('down', 3)
  end

  def add_field(direction, position, field=nil)

    if direction == 'up'
      say 'adding group by contributor and group by number fields to saved vises'
    else
      say 'removing group by contributor and group by number fields to saved vises'
    end

    # Refactor globals for default projects to account for new group by field
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

    # Add field to saved visualization
    Visualization.find_each do |v|
      globals = v.globals.nil? ? nil : JSON.parse(v.globals)
      data = v.data.nil? ? nil : JSON.parse(v.data)

      # update everything field related
      unless globals.nil?
        globals = refactor_globals(globals, direction)
        v.globals = JSON.dump(globals)
      end
      unless data.nil?
        data = refactor_data(data, direction)
        v.data = JSON.dump(data)
      end
 
      # save the new globals and data
      v.save
    end
  end

  # If direction is up, must pass a field, and position to insert it
  # If direction is down, pass the position of the field to remove
  def refactor_data(data, direction, position, field=nil)
    fields = data['fields']
    unless fields.nil?
      if dir == "up"
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
        if dir == 'up'
          # This is the group the data point belongs to. 
          # We need to add the group to every data point
          if field.fieldName == 'Contributors'
            # Every point has a data set name value, we can get the id from that, then we can get the contributor who created it
            # Get data set id between last two parenthesis from data set name, ex. 'Data Set name(101)'
            ds_name = dp[i][0]
            ds_id = ds_name.split('(').last.split(')').first.to_i

            contrib_name = DataSet.find(ds_id).contributor_name
            if contrib_name?
              dp[i].insert(position, contrib_name)
            else 
              user_name User.find(DataSet.find(ds_id).user_id).name
              dp[i].insert(position, user_name)
            end
          elsif field.fieldName == 'Number Fields'
            dp[i].insert(position, 'ALL')
          end

        # down migration
        else 
          dp[i].delete_at(position)
        end
      end
      data['dataPoints'] = dp

      text_fields = data['textFields']
      insert_end = true
      insert_pos = 0
      unless text_fields.nil? or text_fields.length == 0
        text_fields.each_with_index do | f, i |
          # if greater than position, add 1 because it was shifted over
          if f >= position
            insert_end = false
            f++
          end
          if insert_end
            insert_pos = i
          end
        end
        text_fields.insert(insert_pos, position)
      end
      data['textFields'] = text_fields

      time_fields = data['timeFields']
      unless time_fields.nil? or time_fields.length == 0
        time_fields.each_with_index do | f, i |
          # if greater than position, add 1 because it was shifted over
          if f >= position
            f++
          end
        end
      end 
      data['timeFields'] = timeFields

      numeric_fields = data['numericFields']
      unless numeric_fields.nil? or numeric_fields.length == 0
        numeric_fields.each_with_index do | f, i |
          # if greater than position, add 1 because it was shifted over
          if f >= position
            insert_end = false
            f++
          end
        end
      end
      data['numericFields'] = numeric_fields

      geo_fields = data['geoFields']
      unless geo_fields.nil? or geo_fields.length == 0
        geo_fields.each_with_index do | f, i |
          # if greater than position, add 1 because it was shifted over
          if f >= position
            insert_end = false
            f++
          end
        end
      end
      data['geoFields'] = geo_fields

      normal_fields = data['normalFields']
      unless normal_fields.nil? or normal_fields.length == 0
        normal_fields.each_with_index do | f, i |
          # if greater than position, add 1 because it was shifted over
          if f >= position
            insert_end = false
            f++
          end
        end
      end
      data['normalFields'] = normal_fields

      group_selection = data['groupSelection']
      insert_end = true
      insert_pos = 0
      unless group_selection.nil? or group_selection.length == 0
        group_selection.each_with_index do | g, i |
          # if greater than position, add 1 because it was shifted over
          if g >= position
            insert_end = false
            g++
          end
          if insert_end
            insert_pos = i
          end
        end
      end
      data['groupSelection'] = groupSelection
      
    end
  end

  def refactor_globals(data, direction, position, field=nil)
    # global
    subglobals = globals['globals']
    unless subglobals.nil?
      if subglobals['groupById'] >= position
        subglobals['groupById'] += 1
      end
      subglobals['fieldSelection'].each_with_index do | f, i |
        if f >= Param.n
          subglobals['fieldSelection'][i] += 1
        end
      end
      globals['globals'] = subglobals
    end

    # map
    map = globals['Map']
    unless map.nil?
      if !map['heatmapSelection'].nil? && map['heatmapSelection'] >= position
        map['heatmapSelection'] += 1
      end
      globals['Map'] = map
    end

    # timeline
    timeline = refactor_scatter(globals['Timeline'], directiondirection)
    unless timeline.nil?
      globals['Timeline'] = timeline
    end

    # scatter
    scatter = refactor_scatter(globals['Scatter'], direction)
    unless scatter.nil?
      globals['Scatter'] = scatter
    end

    # bar unaffected: axis uses the globals.fieldSelection
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
    table = refactor_table(globals['Table'], direction)
    unless table.nil?
      globals['Table'] = table
    end

    # summary
    summary = globals['Summary']
    unless summary.nil?
      if !summary['displayField'].nil? && summary['displayField'] >= position
        summary['displayField'] += 1
      end
      globals['Summary'] = summary
    end

    globals
  end

  def refactor_scatter(scatter, direction, position)
    if scatter.nil?
      nil
    else
      if !scatter['xAxis'].nil? && scatter['xAxis'] >= Param.n
        scatter['xAxis'] += 1
      end
      unless scatter['yAxis'].nil?
        scatter['yAxis'].each_with_index do | y, i |
          if y >= Param.n
            scatter['yAxis'][i] += 1
          end
        end
      end
      unless scatter['savedRegressions'].nil?
        scatter['savedRegressions'].each do | regres |
          if !regres['xAxis'].nil? && regres['xAxis'] >= Param.n
            regres['xAxis'] += 1
          end
          if !regres['yAxis'].nil? && regres['yAxis'] >= Param.n
            regres['yAxis'] += 1
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
        if t >= Param.n
          table['tableFields'][i] += 1
        end
      end
      if direction == 'up'
        table['tableFields'].push(position)
      else
        table['tableFields'] -= [Param.n]
      end
      table['tableFields'].sort!
      table
    end
  end
end
