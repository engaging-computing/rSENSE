
showEditor = () ->
  ($ '#content-viewer').hide()
  ($ '#content-editor').show()
  ($ '#content-edit-btn').hide()
  ($ '#content-area').summernote(
    height: 400,
    toolbar: [
      ['style', ['style', 'bold', 'italic']],
      ['para', ['ul', 'ol', 'paragraph']],
      ['misc', ['codeview']],
      ['insert', ['picture', 'link', 'video']],
    ]
  )
  
  ($ '#content-area').code($('#content-area').val())

  ($ '#content-area').closest('form').submit ->
    ($ '#content-area').val($('#content-area').code())
    true

hideEditor = () ->
  ($ '#content-editor').hide()
  ($ '#content-viewer').show()
  ($ '#content-edit-btn').show()
  false

$ ->
  if ($ '#content-partial')?
    ($ '#content-editor').hide()
    ($ '#content-edit-btn').click(showEditor)
    if ($ '#add-content-image')?
      ($ '#add-content-image').click(showEditor)
    ($ '#content-cancel-btn').click(hideEditor)