module ProjectsHelper
    
  def project_edit_menu_helper(make_link = false, trunc = 32)
    render 'shared/edit_menu', {type: 'project', typeName: 'Project', obj: @project, make_link: make_link, escape_link: projects_url, trunc: trunc}
  end
  
  def project_edit_helper(field,can_edit = false,make_link = true, trunc = 32)
     render 'shared/edit_info', {type: 'project', field: field, value: @project[field], row_id: @project.id, can_edit: can_edit, make_link: make_link, trunc: trunc}
  end
    
  def project_redactor_helper(can_edit = false)
      render 'shared/content', {type: 'project', field: "content", content: @project.content, row_id: @project.id, has_content: !@project.content.blank?, can_edit: can_edit}
  end
  
  def filter_exists(filter)
    if @project.filter.nil?
      false
    else
      @project.filter.include? filter
    end
  end
  
end
