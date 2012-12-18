module ExperimentSessionsHelper
  
  def experiment_session_edit_helper(field,can_edit = false)
     render 'shared/edit_info', {type: 'experiment_session', field: field, value: @experiment_session[field], row_id: @experiment_session.id, can_edit: can_edit}
  end
    
  def experiment_session_redactor_helper(session, can_edit = false)
      render 'shared/content', {type: 'experiment_session', field: "content", content: session.content, row_id: session.id, has_content: !session.content.blank?, can_edit: can_edit}
  end
  
end
