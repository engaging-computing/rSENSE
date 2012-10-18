module UsersHelper
  
  def user_edit_helper(field,can_edit = false)
     render 'shared/edit_info', {type: 'user', field: field, value: @user[field], row_id: @user.id, can_edit: can_edit}
  end
    
  def user_redactor_helper(can_edit = false)
      render 'shared/content', {type: 'user', field: "content", content: @user.content, row_id: @user.id, can_edit: can_edit}
  end
  
end
