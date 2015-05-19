class AddMeanErrorBars < ActiveRecord::Migration
  def up
    Visualization.find_each do |x|
      y = JSON.parse x.globals
      # Mean with Error was inserted at position 4, so everything 4 or greater
      # gets moved up by 1
      if y['Bar']['analysisType'] >= 4
        y['Bar']['analysisType'] += 1
      end
      x.globals = JSON.dump y
      x.save!
    end
  end

  def down
    Visualization.find_each do |x|
      y = JSON.parse x.globals
      # Mean with Error was inserted at position 4.  This makes everything
      # greater than 4 get shifted down to the correct analysis type, and converts
      # all "Mean with Error" analysis types to just "Mean (average)" analysis
      # types
      if y['Bar']['analysisType'] >= 4
        y['Bar']['analysisType'] -= 1
      end
      x.globals = JSON.dump y
      x.save!
    end
  end
end
