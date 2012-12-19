module FieldsHelper
     
  def field_edit_helper(field,can_edit = false)
     render 'shared/edit_info', {type: 'field', field: field, value: @field[field], row_id: @field.id, can_edit: can_edit}
  end
  
  def get_field_name (field)
      if field == 1
          "Time"
      elsif field == 2
          "Number"
      elsif field == 3
          "Location"
      else
          "Text"
      end
  end
  
  def get_field_type (field)
    if field.is "Time"
      1
    elsif field.is "Number"
      2
    elsif field.is "Location"
      3
    elsif field.is "Text"
      4
    else
      4
    end

end
