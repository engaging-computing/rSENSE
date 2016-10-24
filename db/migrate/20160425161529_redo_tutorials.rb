class RedoTutorials < ActiveRecord::Migration
  def up
    # Tutorials are going to have a completly different form
    # so there is no point in keeping the old ones in the database
    Tutorial.delete_all
    add_column :tutorials, :youtube_url, :string
    add_column :tutorials, :category, :string
    remove_column :tutorials, :featured
    remove_column :tutorials, :featured_at
    remove_column :tutorials, :content
    remove_column :tutorials, :hidden
  end

  def down
    remove_column :tutorials, :youtube_url
    remove_column :tutorials, :category
    add_column :tutorials, :featured, :boolean, default: false
    add_column :tutorials, :featured_at, :datetime
    add_column :tutorials, :content, :text
    add_column :tutorials, :hidden, :boolean, default: true
  end
end
