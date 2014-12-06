class SaveRecords < ActiveRecord::Migration
  def change
    Project.all.each do |p|
      p.save!
    end
    User.all.each do |u|
      u.save!
    end
    Tutorial.all.each do |t|
      t.save!
    end
    News.all.each do |n|
      n.save!
    end
    Visualization.all.each do |v|
      v.save!
    end
  end
end
