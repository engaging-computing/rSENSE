class FixMediaInContents < ActiveRecord::Migration
  def up
    # Then, fix all the "content" attributes.
    [DataSet, News, Project, Tutorial, User, Visualization].each do |model|
      model.all.each do |item|
        while item && item.content =~ /([^\s\"]*amazonaws[^\s\"]*)/
          mo = MediaObject.find_by_src($1)
          mo = MediaObject.find_by_tn_src($1) if mo.nil?
          if mo.nil?
            puts "Skipping deleted media object"
            break
          end

          item.content.gsub!($1, mo.src)
        end

        item.save! if item.changed?
      end
    end
  end

  def down
    puts "Yea, we're not reversing this one either"
  end
end
