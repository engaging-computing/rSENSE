module GroupsHelper
  
  def group_edit_helper(field,can_edit = false)
     render 'shared/edit_info', {type: 'group', field: field, value: @group[field], row_id: @group.id, can_edit: can_edit}
  end
    
  def group_redactor_helper(can_edit = false)
      render 'shared/content', {type: 'group', field: "content", content: @group.content, row_id: @group.id, can_edit: can_edit}
  end  

end
