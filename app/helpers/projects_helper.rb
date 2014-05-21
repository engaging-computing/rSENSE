require 'find'
require 'pathname'

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

  def generic_project_image(id)
    imgs = []

    Find.find Rails.root.join('app/assets/images/placeholders').to_s do |img|
      imgs << image_path("placeholders/" + Pathname.new(img).basename.to_s) if img =~ /\.jpg$/
    end

    imgs[id % imgs.size]
  end
end
