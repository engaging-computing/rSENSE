module GroupsHelper
  
  def group_edit_helper(field,can_edit = false)
     render 'shared/edit_info', {type: 'group', field: field, value: @group[field], row_id: @group.id, can_edit: can_edit}
  end
    
end
