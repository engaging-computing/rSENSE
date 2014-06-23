module TutorialsHelper
  def tutorial_edit_menu_helper(make_link = false)
    render 'shared/edit_menu', type: 'tutorial', typeName: 'Tutorial', obj: @tutorial,
      make_link: make_link, escape_link: tutorials_url
  end

  def tutorial_edit_helper(field, can_edit = false, make_link = true, url = '#')
    render 'shared/edit_info', type: 'tutorial', field: field, value: @tutorial[field],
      row_id: @tutorial.id, can_edit: can_edit, make_link: make_link, href: url
  end
end
