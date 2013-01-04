module ExperimentSessionsHelper
  
  def experiment_session_edit_helper(field,can_edit = false,experiment_session = @experiment_session)
     render 'shared/edit_info', {type: 'experiment_session', field: field, value: experiment_session[field], row_id: experiment_session.id, can_edit: can_edit}
  end
    
  def experiment_session_redactor_helper(session, can_edit = false)
      render 'shared/content', {type: 'experiment_session', field: "content", content: session.content, row_id: session.id, has_content: !session.content.blank?, can_edit: can_edit}
  end
  
  def get_field_id(type)
    if type == "Time"
      1
    elsif type == "Number"
      2
    elsif type == "Location"
      3
    elsif type == "Text"
      4
    end
  end
  
  def get_field_type(id)
    if id == 1
      "Time"
    elsif id == 2
      "Number"
    elsif id == 3
      "Location"
    elsif id == 4
      "Text"
    end
  end
  
end
