namespace :modify_data_sets do
  desc "consolodate pop culture quiz data sets"
  task consolodate_pop_culture: :environment do

    project_id   = Project.where(title: "Pop Culture Opinions 14")[0].id
    longitude_id = Field.where(name: "Longitude", project_id: project_id)[0].id.to_s

    # consolodate data sets
    # if two data sets A and B should be one dataset, merge B into A and then clear B
    DataSet.where(project_id: project_id).each do |ds|
      DataSet.where(project_id: project_id).each do |ds2|
        if ds.id != ds2.id && ds.data != [] && ds2.data != [] &&
           ds.data[0][longitude_id] == ds2.data[0][longitude_id]
          DataSet.find(ds.id).update_attribute(:data, (ds.data.concat ds2.data).uniq)
          DataSet.find(ds2.id).update_attribute(:data, [])
        end
      end
    end

    # delete all cleared datasets (B)
    DataSet.where(project_id: project_id, data: "[]").destroy_all

    # make the age field a number instead of text
    Field.where(project_id: project_id, name: "Age")[0].update_attribute(:field_type, 2)

  end
end
