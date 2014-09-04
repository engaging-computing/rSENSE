module VisualizationsHelper
  def visualization_edit_helper(field, can_edit = false, make_link = true, url = '#')
    render 'shared/edit_info', type: 'visualization', field: field, value: @visualization[field],
      row_id: @visualization.id, can_edit: can_edit, make_link: make_link, href: url
  end
end
