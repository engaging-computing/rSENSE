module DataSetsHelper
  
  def data_set_edit_menu_helper(id, make_link = false)
    
    @data_set = DataSet.find_by_id(id)
    datasets = params['datasets'].split(",").map {|n| n.to_i}
    datasets.delete id
    escapeLink = "#"
    
    render 'shared/edit_menu', {type: 'data_set', typeName: 'Data Set', obj: @data_set, make_link: make_link, escape_link: escapeLink}
  end
  
  def data_set_edit_helper(field,can_edit = false, make_link = true)
     render 'shared/edit_info', {type: 'data_set', field: field, value: @data_set[field], row_id: @data_set.id, can_edit: can_edit, make_link: make_link}
  end
    
  def data_set_redactor_helper(dataset, can_edit = false)
      render 'shared/content', {type: 'data_set', field: "content", content: dataset.content, row_id: dataset.id, has_content: !dataset.content.blank?, can_edit: can_edit}
  end
  
  def get_field_id(type)
    if type == "Time"
      1
    elsif type == "Number"
      2
    elsif type == "Location"
      3
    elsif type == "Text"
      4
    end
  end
  
  def get_field_type(id)
    if id == 1
      "Time"
    elsif id == 2
      "Number"
    elsif id == 3
      "Location"
    elsif id == 4
      "Text"
    end
  end
  
end
