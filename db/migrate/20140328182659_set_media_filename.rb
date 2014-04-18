class SetMediaFilename < ActiveRecord::Migration
  def up
    MediaObject.all.each do |mo|
      mo.file = mo.name
      mo.save!
    end
  end

  def down
  end
end
