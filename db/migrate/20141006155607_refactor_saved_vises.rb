class RefactorSavedVises < ActiveRecord::Migration
  def update(old_key, new_key, vis)
    temp = vis[old_key]
    vis[new_key] = temp
    vis.delete(old_key)
  end

  def refactor_keys(regression)
    update('type_count', 'typeCount', regression)
    update('field_names', 'fieldNames', regression)
    update('field_indices', 'fieldIndices', regression)
    update('regression_id', 'regressionId', regression)
  end

  def refactor_keys_undo(regression)
    update('typeCount', 'type_count', regression)
    update('fieldNames', 'field_names', regression)
    update('fieldIndices', 'field_indices', regression)
    update('regressionId', 'regression_id', regression)
  end

  def up
    say 'Refactoring saved visualizations'
    # Extract the data/globals -> JSON.parse(Project.find(#).var)
    Visualization.find_each do | v |
      globals = JSON.parse(v.globals)
      data = JSON.parse(v.data)

      refactor(globals, data)

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

      refactor_undo(globals, data)

      # Update the globals
      v.globals = JSON.dump(globals)
      v.data = JSON.dump(data)
      v.save
    end
  end
end
