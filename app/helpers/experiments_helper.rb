module ExperimentsHelper
    
  def experiment_edit_helper(field,can_edit = false)
     render 'shared/edit_info', {type: 'experiment', field: field, value: @experiment[field], row_id: @experiment.id, can_edit: can_edit}
  end
    
  def experiment_redactor_helper(can_edit = false)
      render 'shared/content', {type: 'experiment', field: "content", content: @experiment.content, row_id: @experiment.id, has_content: !@experiment.content.blank?, can_edit: can_edit}
  end  
  
end
