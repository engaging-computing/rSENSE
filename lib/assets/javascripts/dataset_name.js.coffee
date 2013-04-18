$ ->
  
  window.helpers ?= {}
  
  helpers.name_dataset = (title, id, succ) ->
    modal = """
    <div id="name_dataset_box" class="modal hide fade well container" style="width:400px">
      <div> Please enter a name for this Dataset. <br>
        <input id="name_dataset_name" class="name_field" type="text" style="width:75%" value="#{title}"></input>
        </div>
        <div class="clear"></div>
      <div style="float:right;">
          <button class="name_dataset_button btn btn-success">Finish</button>
      </div>
    </div>
    """
  # Control code for name popup box
    ($ 'body').append modal
    ($ '#name_dataset_box').modal();
    selectFunc = ->
      ($ '#name_dataset_name').select()
    setTimeout selectFunc, 300
    
    ($ '#name_dataset_name').keyup (e) ->
      if (e.keyCode == 13)
        ($ '.name_dataset_button').click()
    
    ($ '.name_dataset_button').click ->
      name = ($ '#name_dataset_name').val()
      data = 
        data_set:
          title: name
          
      $.ajax
        url: "/data_sets/#{id}"
        type: 'PUT'
        dataType: 'json'
        data: data
        success: ->
          succ()