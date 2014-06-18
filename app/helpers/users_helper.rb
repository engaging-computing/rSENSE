module UsersHelper
  def user_edit_helper(field, can_edit = false, make_link = true, url = '#')
    render 'shared/edit_info', type: 'user', field: field, value: @user[field], row_id: @user.id,
      can_edit: can_edit, make_link: make_link, href: url
  end
end
