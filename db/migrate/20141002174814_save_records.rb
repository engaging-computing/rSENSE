class SaveRecords < ActiveRecord::Migration
  def change
    Project.all.each(&:save!)
    User.all.each(&:save!)
    Tutorial.all.each(&:save!)
    News.all.each(&:save!)
    Visualization.all.each(&:save!)
  end
end
