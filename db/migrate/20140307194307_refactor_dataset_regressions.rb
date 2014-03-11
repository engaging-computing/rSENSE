class RefactorDatasetRegressions < ActiveRecord::Migration
  def change
   
    def update(old_key, new_key, vis)
      temp = vis[old_key]
      vis[new_key] = temp
      vis.delete(old_key)
    end
    
    def refactor_keys(regression)
      update("type_count", "typeCount", regression)
      update("field_names", "fieldNames", regression)
      update("field_indices", "fieldIndices", regression)
      update("regression_id", "regressionId", regression)
    end
    
    say "Refactoring scatter plots"
    #JSON.parse(Visualization.find(5).globals)["scatter"]["savedRegressions"]
    Visualization.find_each do |viz|
      globals = JSON.parse(viz.globals)
 
      regressions = globals["scatter"]["savedRegressions"]
      unless regressions.nil?
        regressions.each do |regression|
          refactor_keys(regression)
        end
      end
      
      # Update the globals
      viz.globals = JSON.dump(globals)
      viz.save
    end
    
    say "Refactoring timelines"
    #JSON.parse(Visualization.find(5).globals)["timeline"]["savedRegressions"]
    Visualization.find_each do |viz|
      globals = JSON.parse(viz.globals)

      regressions = globals["timeline"]["savedRegressions"]
      unless regressions.nil?
        regressions.each do |regression|
          refactor_keys(regression)
        end
      end
      
      # Update the globals
      viz.globals = JSON.dump(globals)
      viz.save
    end
  end
end
