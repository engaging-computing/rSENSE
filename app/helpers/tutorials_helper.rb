module TutorialsHelper
  
  def tutorial_edit_menu_helper(make_link = false, trunc = 32)
    render 'shared/edit_menu', {type: 'tutorial', typeName: 'Tutorial', obj: @tutorial, make_link: make_link, escape_link: tutorials_url, trunc: trunc}
  end
  
  def tutorial_redactor_helper(can_edit = false, trunc = 32)
    render 'shared/content', {type: 'tutorial', field: 'content', content: @tutorial.content, row_id: @tutorial.id, has_content: !@tutorial.content.blank?, can_edit: can_edit, trunc: trunc}
  end
  
  def tutorial_edit_helper(field,can_edit = false,make_link = true)
     render 'shared/edit_info', {type: 'tutorial', field: field, value: @tutorial[field], row_id: @tutorial.id, can_edit: can_edit, make_link: make_link}
  end
end
