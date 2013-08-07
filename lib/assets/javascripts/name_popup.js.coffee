$ ->
  
  window.helpers ?= {}
  
  helpers.name_popup = (obj, name, type) ->
    console.log 'here'
    modal = """
    <div id="new_name_box" class="modal hide fade well container" style="width:400px">
      <div> Please enter a name for this #{name}: <br>
        <input id="new_name" class="name_field" type="text" style="width:75%" value="#{obj.name}"></input>
        </div>
        <div class="clear"></div>
      <div style="float:right;">
          <button class="new_name_button" btn btn-success">Finish</button>
      </div>
    </div>
    """
    # Control code for name popup box
    ($ 'body').append modal
    ($ "#new_name_box").modal()
    
    submit_modal = ->
      edit_box = ($ "#new_name")
      name = edit_box.val()
      data = {}
      data[type] =
          title: name
          
      $.ajax
        url: obj.url
        type: 'PUT'
        dataType: 'json'
        data: data
        success: ->
          ($ "#new_name_box").modal("hide")
        error: (j, s, t) =>
          edit_box.errorFlash()
          
          errors = JSON.parse j.responseText
          edit_box.popover
            content: errors[0]
            placement: "bottom"
            trigger: "manual"
          edit_box.popover 'show'
    
    
    ($ "#new_name_box").on 'hidden', ->
      window.location = obj.url
    
    selectFunc = ->
      ($ "#new_name").select()
    setTimeout selectFunc, 300
    
    ($ "#new_name").keyup (e) ->
      if (e.keyCode == 13)
        submit_modal()
    
    ($ ".new_name_button").click ->
      submit_modal()