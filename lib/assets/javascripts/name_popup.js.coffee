$ ->
  
  window.helpers ?= {}
  
  helpers.name_popup = (obj, name, type, escape_location = "#") ->
    
    modal = """
    <div id="new_name_box" class="modal fade" role="dialog" aria-hidden="true">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h4> Please enter a name for this #{name}: </h4>
          </div>
          <div class="modal-body">
            <input id="new_name" class="form-control" type="text" style="width:95%" value="#{obj.name}">
          </div>
          <div class="modal-footer">
              <button class="cancel_new_button btn btn-danger">Cancel</button>
              <button class="new_name_button btn btn-success">Finish</button>
          </div>
        </div>  
      </div>  
    </div>
    """
    
    # Control code for name popup box
    ($ 'body').append modal
    ($ "#new_name_box").modal()
    
    ($ ".cancel_new_button").click (e) ->
      $.ajax
        url: obj.url
        type: 'DELETE'
        dataType: 'json'
        error: ->
          ($ "#new_name_box").modal("hide")
          ($ "#new_name_box").on('hidden.bs.modal', -> ($ "#new_name_box").remove())
          alert ("The project was created. Please delete it from the Projects page.")
        success: ->  
          ($ "#new_name_box").modal("hide")
          ($ "#new_name_box").on('hidden.bs.modal', -> ($ "#new_name_box").remove())
          window.location = escape_location
      
    ($ ".new_name_button").click (e) ->
      edit_box = ($ "#new_name")
      name = edit_box.val()
      data = {}
      data[type] =
        title: name
        
      edit_box.find('.new_name_button').button 'disable'
      edit_box.find('.cancel_new_button').button 'disable'
      edit_box.find('.new_name_button').addClass 'disabled'
      edit_box.find('.cancel_new_button').addClass 'disabled'
          
      $.ajax
        url: obj.url
        type: 'PUT'
        dataType: 'json'
        data: data
        success: ->
          ($ "#new_name_box").modal("hide")
          window.location = obj.url
        error: (j, s, t) =>
          edit_box.errorFlash()
          
          errors = JSON.parse j.responseText
          edit_box.popover
            content: errors[0]
            placement: "bottom"
            trigger: "manual"
          edit_box.popover 'show'
        complete: ->
          edit_box.find('.new_name_button').button 'enable'
          edit_box.find('.cancel_new_button').button 'enable'
          edit_box.find('.new_name_button').removeClass 'disabled'
          edit_box.find('.cancel_new_button').removeClass 'disabled'
    
    selectFunc = ->
      ($ "#new_name").select()
    setTimeout selectFunc, 300
    
    ($ "#new_name").keyup (e) ->
      if (e.keyCode == 13)
        $(".new_name_button").trigger 'click'
    
