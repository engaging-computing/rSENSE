module UsersHelper
  
  def user_edit_helper(field,can_edit = false,make_link = true)
     render 'shared/edit_info', {type: 'user', field: field, value: @user[field], row_id: @user.username, can_edit: can_edit, make_link: make_link}
  end
    
  def user_redactor_helper(can_edit = false)
      render 'shared/content', {type: 'user', field: "content", content: @user.content, row_id: @user.username,has_content: !@user.content.blank? , can_edit: can_edit}
  end
  
end
