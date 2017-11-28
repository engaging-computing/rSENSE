namespace :modify_data_sets do
  desc "consolodate pop culture quiz data sets"
  task consolodate_pop_culture_data_sets: :environment do

    project_id   = Project.where(title: "Pop Culture Opinions")[0].id
    longitude_id = Field.where(name: "Longitude", project_id: project_id)[0].id.to_s

    DataSet.where(project_id: project_id).each do |ds|
      DataSet.where(project_id: project_id).each do |ds2|
        if ds.id != ds2.id && ds.data != [] && ds2.data != [] &&
           ds.data[0][longitude_id] == ds2.data[0][longitude_id]
          DataSet.find(ds.id).update_attribute(:data, (ds.data.concat ds2.data).uniq)
          DataSet.find(ds2.id).update_attribute(:data, [])
        end
      end
    end

    DataSet.where(project_id: project_id, data: "[]").destroy_all

  end
end
