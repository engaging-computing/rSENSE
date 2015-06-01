class AddMeanErrorBars < ActiveRecord::Migration
  def up
    # Fix all saved visualizations to accomondate the new analysis type
    Visualization.find_each do |x|
      next if x.globals.nil?
      y = JSON.parse x.globals
      next if y['Bar'].empty?

      # Mean with Error was inserted at position 4, so everything 4 or greater
      # gets moved up by 1
      if !y['Bar'].nil? and !y['Bar']['analysisType'].nil? and y['Bar']['analysisType'] >= 4
        y['Bar']['analysisType'] += 1
      end

      if !y['Pie'].nil? and !y['Pie']['analysisType'].nil? and y['Pie']['analysisType'] >= 4
        y['Pie']['analysisType'] += 1
      end

      x.globals = JSON.dump y
      x.save!
    end

    # Do the same as above, but for default visualizations
    Project.find_each do |x|
      next if x.globals.nil?
      y = JSON.parse x.globals

      if !y['Bar'].nil? and !y['Bar']['analysisType'].nil? and y['Bar']['analysisType'] >= 4
        y['Bar']['analysisType'] += 1
      end

      if !y['Pie'].nil? and !y['Pie']['analysisType'].nil? and y['Pie']['analysisType'] >= 4
        y['Pie']['analysisType'] += 1
      end

      x.globals = JSON.dump y
      x.save!
    end
  end

  def down
    # Fix all saved visualizations to revert back to the old analysis types
    Visualization.find_each do |x|
      next if x.globals.nil?
      y = JSON.parse x.globals

      # Mean with Error was inserted at position 4.  This makes everything
      # greater than 4 get shifted down to the correct analysis type, and converts
      # all "Mean with Error" analysis types to just "Mean (average)" analysis
      # types
      if !y['Bar'].nil? and !y['Bar']['analysisType'].nil? and y['Bar']['analysisType'] >= 4
        y['Bar']['analysisType'] -= 1
      end

      if !y['Pie'].nil? and !y['Pie']['analysisType'].nil? and y['Pie']['analysisType'] >= 4
        y['Pie']['analysisType'] -= 1
      end

      x.globals = JSON.dump y
      x.save!
    end

    # Do the same as above, but for default visualizations
    Project.find_each do |x|
      next if x.globals.nil?
      y = JSON.parse x.globals

      if !y['Bar'].nil? and !y['Bar']['analysisType'].nil? and y['Bar']['analysisType'] >= 4
        y['Bar']['analysisType'] -= 1
      end

      if !y['Pie'].nil? and !y['Pie']['analysisType'].nil? and y['Pie']['analysisType'] >= 4
        y['Pie']['analysisType'] -= 1
      end

      x.globals = JSON.dump y
      x.save!
    end
  end
end
