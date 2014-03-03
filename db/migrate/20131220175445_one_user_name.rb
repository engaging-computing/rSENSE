class OneUserName < ActiveRecord::Migration
  def up
    add_column :users, :name, :string

    User.all.to_a.each do |uu|
      uu.name = "#{uu.firstname} #{uu.lastname[0]}"

      if uu.email.empty?
        uu.email = "#{uu.username}.fake@example.com"
      end

      uu.save!
    end
  end

  def down
    remove_column :users, :name
  end
end
