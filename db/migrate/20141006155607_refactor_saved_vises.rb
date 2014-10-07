class RefactorSavedVises < ActiveRecord::Migration
  def update(old_key, new_key, obj)
    obj[new_key] = obj[old_key]
    obj.delete(old_key)
  end

  def move_to_obj(key, old_obj, new_obj)
    new_obj[key] = old_obj[key]
    old_obj.delete(key)
  end

  def rupdate(old_key, new_key, vis)
    update(new_key, old_key, vis)
  end

  def rmove_to_obj(key, old_obj, new_obj)
    move_to_obj(key, new_obj, old_obj)
  end

  def refactor_names(obj, func)
    func('selectedGroup', 'groupById', obj)
    func('map', 'Map', obj)
    func('timeline', 'Timeline', obj)
    func('scatter', 'Scatter', obj)
    func('bar', 'Bar', obj)
    func('histogram', 'Histogram', obj)
    func('pie', 'Pie', obj)
    func('table', 'Table', obj)
    func('summary', 'Summary', obj)
    func('photos', 'Photos', obj)
  end

  def move_vars(globals, data, func)
    func('groupSelection', globals, data)
  end

  def extract_globals(key, globals, temp, func)
    func(key, globals, temp)
  end

  vises = ['Map', 'Timeline', 'Scatter', 'Bar', 'Histogram', 'Pie', 'Table', 'Summary', 'Photos']

  def up
    say 'Refactoring saved visualizations'
    # Extract the data/globals -> JSON.parse(Project.find(#).var)
    Visualization.find_each do | v |
      globals = JSON.parse(v.globals)
      data = JSON.parse(v.data)

      # Updating variable names
      refactor_names(globals, update)

      # Moving group selection to globals
      move_vars(globals, data, move_to_obj)

      # Pull out anything that's not in vises into a globals object
      temp = {}
      for key in globals.keys when !vises.include?(key)
        extract_globals(key, globals, temp, move_to_obj)
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
    Visualization.find_each do | v |
      globals = JSON.parse(proj.globals)
      data = JSON.parse(proj.data)

      # Revert back to the previous configurations
      temp = globals['globals']
      globals.delete('globals')
      for key in temp.keys
        extract_globals(key, globals, temp, rmove_to_obj)
      end
      move_vars(globals, data, rmove_to_obj)
      refactor_names(globals, rupdate)

      # Update the globals
      v.globals = JSON.dump(globals)
      v.data = JSON.dump(data)
      v.save
    end
  end
end
