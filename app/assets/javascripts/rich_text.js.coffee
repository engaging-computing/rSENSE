
showEditor = () ->
  $('#content-viewer').hide()
  $('#content-editor').show()

  $('#content-area').summernote({
    height: 400,
    toolbar: [
      ['style', ['style', 'bold', 'italic']],
      ['para', ['ul', 'ol', 'paragraph']],
      ['misc', ['codeview']],
      ['insert', ['picture', 'link']],
    ],
  })

  $('#content-area').code($('#content-area').val())

  $('#content-area').closest('form').submit ->
    $('#content-area').val($('#content-area').code())
    true

hideEditor = () ->
  $('#content-editor').hide()
  $('#content-viewer').show()
  false

$ ->
  if $('#content-partial')?
    $('#content-editor').hide()
    $('#content-edit-btn').click(showEditor)
    if $('#add-content-image')?
      $('#add-content-image').click(showEditor)
    $('#content-cancel-btn').click(hideEditor)

  $('.summernote').summernote(
    height: 200,
    onImageUpload: (files, editor, w) ->
      sendFile(files[0], editor, w)
  )
  sendFile( file, editor, w) ->
    data = new FormData
    data.append("file", file)
    $.ajax 
      data: data,
      type: "POST"
      url: ""
      cache: false,
      contentType: false,
      processData,
      success: (url) ->
        editor.insertImage(w, url)
