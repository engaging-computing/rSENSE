module UsersHelper
  
  def edit_helper(field,can_edit = false)
     render 'shared/edit_info', {type: 'user', field: field, value: @user[field], row_id: @user.id, can_edit: can_edit}
  end
    
end
