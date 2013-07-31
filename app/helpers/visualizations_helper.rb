module VisualizationsHelper

  def visualization_edit_menu_helper(make_link = false, trunc = 32)
    render 'shared/edit_menu', {type: 'visualization', typeName: 'Visualization', obj: @visualization, make_link: make_link, escape_link: visualizations_url, trunc: trunc}
  end
  
  def visualization_edit_helper(field,can_edit = false,make_link = true, trunc = 32)
     render 'shared/edit_info', {type: 'visualization', field: field, value: @visualization[field], row_id: @visualization.id, can_edit: can_edit, make_link: make_link, trunc: trunc}
  end
  
  def visualization_redactor_helper(can_edit = false)
      render 'shared/content', {type: 'visualization', field: "content", content: @visualization.content, row_id: @visualization.id, has_content: !@visualization.content.blank?, can_edit: can_edit}
  end
  
end
