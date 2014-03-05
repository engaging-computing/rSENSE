module DataSetsHelper
  def data_set_edit_helper(field, can_edit = false, make_link = true)
    render 'shared/edit_info', type: 'data_set', field: field, value: @data_set[field],
      row_id: @data_set.id, can_edit: can_edit, make_link: make_link
  end

  def data_set_content_helper(dataset, can_edit = false)
    render 'shared/newcontent', type: 'data_set', field: 'content', content: dataset.content,
      row_id: dataset.id, has_content: !dataset.content.blank?, can_edit: can_edit
  end
end
