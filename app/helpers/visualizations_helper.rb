module VisualizationsHelper

  def visualization_edit_helper(field,can_edit = false,make_link = true)
     render 'shared/edit_info', {type: 'visualization', field: field, value: @visualization[field], row_id: @visualization.id, can_edit: can_edit, make_link: make_link}
  end
  
  def visualization_redactor_helper(can_edit = false)
      render 'shared/content', {type: 'visualization', field: "content", content: @visualization.content, row_id: @visualization.id, has_content: !@visualization.content.blank?, can_edit: can_edit}
  end
  
end
