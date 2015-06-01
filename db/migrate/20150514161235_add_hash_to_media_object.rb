class AddHashToMediaObject < ActiveRecord::Migration
  def isFeatured?(mo)
    if !mo.project_id.nil?
      owner = Project.find mo.project_id
      featured_id = owner.featured_media_id
    elsif !mo.tutorial_id.nil?
      owner = Tutorial.find mo.tutorial_id
      featured_id = owner.featured_media_id
    elsif !mo.visualization_id.nil?
      owner = Visualization.find mo.visualization_id
      featured_id = owner.thumb_id
    elsif !mo.news_id.nil?
      owner = News.find mo.news_id
      featured_id = owner.featured_media_id
    else
      nil
    end

    if owner.nil?
      false
    elsif mo.id == featured_id
      true
    else
      false
    end
  end

  def up
    add_column :media_objects, :md5, :string

    resave = []

    MediaObject.find_each do |mo|
      if File.exist? mo.file_name
        mo.md5 = Digest::MD5.file(mo.file_name).hexdigest
      end
      mo.save!
    end 
  end

  def down
    remove_column :media_objects, :md5
  end
end
