class RefactorSavedVises < ActiveRecord::Migration
  def update(old_key, new_key, obj)
    obj[new_key] = obj[old_key]
    obj.delete(old_key)
  end

  def move_to_obj(key, old_obj, new_obj)
    new_obj[key] = old_obj[key]
    old_obj.delete(key)
  end

  def rupdate(old_key, new_key, obj)
    update(new_key, old_key, obj)
  end

  def rmove_to_obj(key, old_obj, new_obj)
    move_to_obj(key, new_obj, old_obj)
  end

  def refactor_names(obj)
    # Only for summary and there are no summary savedVises
    obj.delete('selectedGroup')

    update('map', 'Map', obj)
    update('timeline', 'Timeline', obj)
    update('scatter', 'Scatter', obj)
    update('bar', 'Bar', obj)
    update('histogram', 'Histogram', obj)
    update('pie', 'Pie', obj)
    update('table', 'Table', obj)
    update('summary', 'Summary', obj)
    update('photos', 'Photos', obj)
  end

  def undo_refactor_names(obj)
    rupdate('map', 'Map', obj)
    rupdate('timeline', 'Timeline', obj)
    rupdate('scatter', 'Scatter', obj)
    rupdate('bar', 'Bar', obj)
    rupdate('histogram', 'Histogram', obj)
    rupdate('pie', 'Pie', obj)
    rupdate('table', 'Table', obj)
    rupdate('summary', 'Summary', obj)
    rupdate('photos', 'Photos', obj)
  end

  def move_vars(globals, data)
    move_to_obj('groupSelection', globals, data)
    move_to_obj('groupingFieldIndex', data, globals)
    update('groupingFieldIndex', 'groupById', globals)
  end

  def undo_move_vars(globals, data)
    rmove_to_obj('groupSelection', globals, data)
    rupdate('groupingFieldIndex', 'groupById', globals)
    rmove_to_obj('groupingFieldIndex', data, globals)
  end

  def extract_globals(key, globals, temp)
    move_to_obj(key, globals, temp)
  end

  def undo_extract_globals(key, globals, temp)
    rmove_to_obj(key, globals, temp)
  end

  def up
    vises = ['Map', 'Timeline', 'Scatter', 'Bar', 'Histogram', 'Pie', 'Table', 'Summary', 'Photos']

    say 'Refactoring saved visualizations'
    # Extract the data/globals -> JSON.parse(Project.find(#).var)
    Visualization.find_each do |v|
      globals = JSON.parse(v.globals)
      data = JSON.parse(v.data)

      # Updating variable names
      refactor_names(globals)

      # Moving group selection to globals
      move_vars(globals, data)

      # Pull out anything that's not in vises into a globals object
      temp = {}
      globals.keys.each do |key|
        unless vises.include?(key)
          extract_globals(key, globals, temp)
        end
      end
      globals['globals'] = temp

      # Update the globals and data
      v.globals = JSON.dump(globals)
      v.data = JSON.dump(data)
      v.save
    end
  end

  def down
    say 'Restoring saved visualization format'
    # Extract the data/globals -> JSON.parse(Project.find(#).var)
    Visualization.find_each do |v|
      globals = JSON.parse(v.globals)
      data = JSON.parse(v.data)

      # Revert back to the previous configurations
      temp = globals['globals']
      temp.keys.each do |key|
        undo_extract_globals(key, globals, temp)
      end
      undo_move_vars(globals, data)
      undo_refactor_names(globals)

      globals.delete('globals')

      # Update the globals
      v.globals = JSON.dump(globals)
      v.data = JSON.dump(data)
      v.save
    end
  end
end
