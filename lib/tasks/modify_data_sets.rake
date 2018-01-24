namespace :modify_data_sets do
  desc "consolidate pop culture quiz data sets"
  task consolidate_pop_culture: :environment do

    x = Time.now

    project_id   = Project.find(3177).id
    longitude_id = Field.where(name: "Longitude", project_id: project_id)[0].id.to_s

    datasets = DataSet.where(project_id: project_id)
    grouped_datasets = datasets.group_by { |ds| ds.data[0][longitude_id] }

    grouped_datasets.each do |k,v|
      merged_data = v.map { |ds| ds.data }.flatten
      merged_ids = v.map { |ds| ds.id }
      DataSet.where(id: merged_ids).each do |ds|
        ds.update_attribute(:data, [])
      end
      DataSet.find(merged_ids.first).update_attribute(:data, merged_data)
    end

    # delete all cleared datasets (B)
    DataSet.where(project_id: project_id, data: "[]").destroy_all

    # make the age field a number instead of text
    Field.where(project_id: project_id, name: "Age")[0].update_attribute(:field_type, 2)

    y = Time.now

    puts "time taken:"
    puts y - x

  end
end
