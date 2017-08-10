$ ->
  if namespace.controller is "projects" and namespace.action is "edit"

    $('#enter-project-tag-name').keypress (e) ->
      if e.keyCode == 10 or e.keyCode == 13
        e.preventDefault()

    $('#project-tag-list').on 'click', '.remove-tag', (e) ->
      tagId = $(e.currentTarget).data("id")
      $(e.currentTarget).parent().remove()
      $.ajax
        dataType: 'text'
        url: '/projects/remove_tag'
        type: 'DELETE'
        data:
          id: namespace.id
          tagId: tagId

    $('#add-project-tag').click ->
      if (tagName = $('#enter-project-tag-name').val()) isnt ''
        if ($("#project-tag-list>li").filter () -> $.trim($(this).text()) is tagName).length is 0
          $('#enter-project-tag-name').val('')
          $.ajax
            dataType: 'text'
            url: '/projects/create_tag'
            type: 'POST'
            data:
              id: namespace.id
              name: tagName
            success: (res) ->
              tagId = JSON.parse(res)["id"]
              tagName = JSON.parse(res)["name"]
              $('#project-tag-list').append $('<li/>',
                class: "list-group-item",
                html: "<span>#{tagName}</span>
                  <span class='glyphicon glyphicon-remove remove-tag'
                    data-id='#{tagId}'>
                  </span>")
        else
          alert "Tag already exists."
                