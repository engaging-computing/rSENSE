module ProjectsHelper
  def project_edit_menu_helper(make_link = false)
    render 'shared/edit_menu', type: 'project', typeName: 'Project', obj: @project,
      make_link: make_link, escape_link: projects_url
  end

  def project_edit_helper(field, can_edit = false, make_link = true)
    render 'shared/edit_info', type: 'project', field: field, value: @project[field],
      row_id: @project.id, can_edit: can_edit, make_link: make_link
  end

  def can_contribute?(project)
    session[:contrib_access] == project.id ||
      (@cur_user.try(:id) && !project.lock?)
  end
end
