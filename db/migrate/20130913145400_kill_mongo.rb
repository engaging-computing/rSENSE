class KillMongo < ActiveRecord::Migration
  def up
    add_column :data_sets, :data, :text, default: '[]', null: false

    DataSet.all.each do |ds|
      md = MongoData.find_by_data_set_id(ds.id)
      if md
        ds.data = []
        md.data.each do |row|
          if row.inspect[0] == '['
            ds.data.push(row.inject {|acc, xx| acc.merge(xx) })
          elsif row.inspect[0] == '{'
            ds.data.push(row)
          else
            puts row.inspect
            puts "No idea what's going on"
            raise Exception.new("I give up")
          end
        end
        ds.save!
      end
    end
  end

  def down
    remove_column :data_sets, :data
  end
end
