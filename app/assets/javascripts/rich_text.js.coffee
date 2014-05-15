
IS.onSetup ->
  $('.rich-text').each (_, area) ->
    new nicEditor({
      iconsPath: IS.imagePath('nicEditorIcons.gif'),
      buttonList: ['fontFormat', 'bold', 'italic', 'ol', 'ul', 'indent', 'outdent', 'link', 'unlink', 'xhtml'],
    }).panelInstance($(area).attr('id'))

