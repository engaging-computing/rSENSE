class ChangeProjectsGlobals < ActiveRecord::Migration
  def change
    reversible do |dir|
      change_table :projects do |p|
        dir.up   { p.change :globals, :text, limit: nil }
        dir.down { p.change :globals, :string }
      end
    end
  end
end
