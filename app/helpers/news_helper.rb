module NewsHelper
    
  def news_edit_menu_helper(make_link = false)
    render 'shared/edit_menu', {type: 'news', typeName: 'News', obj: @news, make_link: make_link, escape_link: "/news"}
  end
  
  def news_redactor_helper(can_edit = false)
    render 'shared/content', {type: 'news', field: 'content', content: @news.content, row_id: @news.id, has_content: !@news.content.blank?, can_edit: can_edit}
  end
  
  def news_edit_helper(field,can_edit = false,make_link = true)
    render 'shared/edit_info', {type: 'news', field: field, value: @news[field], row_id: @news.id, can_edit: can_edit, make_link: make_link}
  end
  
end
