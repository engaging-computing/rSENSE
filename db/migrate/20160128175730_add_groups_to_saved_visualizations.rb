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

    # Add field to default project
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
    end




  end

  def refactor_globals(data, direction, position, field=nil)


  end
end
