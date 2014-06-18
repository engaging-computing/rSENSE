module DataSetsHelper
  def data_set_edit_helper(field, can_edit = false, make_link = true, url = '#')
    render 'shared/edit_info', type: 'data_set', field: field, value: @data_set[field],
      row_id: @data_set.id, can_edit: can_edit, make_link: make_link, href: url
  end
end
