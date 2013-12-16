module UsersHelper
  
  def user_edit_helper(field,can_edit = false, make_link = true)
     render 'shared/edit_info', {type: 'user', field: field, value: @user[field], row_id: @user.username, can_edit: can_edit, make_link: make_link}
  end
    
  def user_content_helper(can_edit = false, field = "content", upload = true, simple = false)
    
    content = @user.bio

    render 'shared/newcontent', {type: 'user', field: field, content: content, row_id: @user.username, has_content: !content.blank? , can_edit: can_edit, no_redactor_upload: !upload, simple_redactor_toolbar: simple}
  end
  
end
