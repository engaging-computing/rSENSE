module MediaObjectsHelper
  def media_object_edit_helper(field,can_edit = false)
     render 'shared/edit_info', {type: 'media_object', field: field, value: @media_object[field], row_id: @media_object.id, can_edit: can_edit}
  end
    
  def media_object_redactor_helper(can_edit = false)
      render 'shared/content', {type: 'media_object', field: "content", content: @media_object.content, row_id: @media_object.id, has_content: !@media_object.content.blank?, can_edit: can_edit}
  end  
end