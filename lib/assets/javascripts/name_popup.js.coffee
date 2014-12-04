$ ->

  window.helpers ?= {}

  helpers.name_popup = (name, objType, rootId, onSuccess, onDismiss) ->

    modal = """
    <div id="nname_box" class="modal fade" role="dialog" aria-hidden="true">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h4> Please enter a name for this #{objType}: </h4>
          </div>
          <div class="modal-body">
            <input id="nname" class="form-control" type="text"
              style="width:95%" value="#{name}">
          </div>
          <div class="modal-footer">
            <button id="nname_cancel_btn" class="btn btn-danger">Cancel</button>
            <button id="nname_btn" class="btn btn-success">Finish</button>
          </div>
        </div>
      </div>
    </div>
    """

    # Control code for name popup box
    unless $('#nname_box').length then ($ rootId).append modal
    ($ "#nname_box").modal()

    # These are precautions to prevent multiple click calls
    $('#nname_btn').unbind('click')
    $('#nname_btn').one 'click', (e) ->
      edit_box = ($ "#nname")
      name = edit_box.val()

      ($ '#nname_box').modal('hide')
      if onSuccess? then onSuccess(name)

    ($ "#nname_cancel_btn").one 'click', (e) ->
      ($ '#nname_box').modal('hide')
      if onDismiss? then onDismiss()

    selectFunc = ->
      ($ "#nname").select()
    setTimeout selectFunc, 300

    ($ "#nname").keyup (e) ->
      if (e.keyCode is 13)
        $("#nname_btn").trigger 'click'
