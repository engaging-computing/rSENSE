require 'find'
require 'pathname'

module ProjectsHelper
  def project_edit_helper(field, can_edit = false, make_link = true, url = '#')
    render 'shared/edit_info', type: 'project', field: field, value: @project[field],
      row_id: @project.id, can_edit: can_edit, make_link: make_link, href: url
  end

  def can_contribute?(project)
    session[:contrib_access] == project.id ||
      (current_user.try(:id) && !project.lock?)
  end

  def is_deleted?(project)
    if project.user_id == -1
      true
    else
      false
    end
  end
end
