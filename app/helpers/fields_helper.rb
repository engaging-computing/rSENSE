module FieldsHelper
     
  def field_edit_helper(field,can_edit = false)
     render 'shared/edit_info', {type: 'field', field: field, value: @field[field], row_id: @field.id, can_edit: can_edit}
  end

end
