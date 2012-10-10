module UsersHelper
  
  def edit_helper(field,can_edit)
     render 'shared/edit_info', {type: 'user', field: field, value: @user[field], label: field.capitalize, row_id: @user.id, can_edit: can_edit}
  end
    
end
