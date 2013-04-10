module MediaObjectsHelper
  def media_object_edit_helper(field,can_edit = false)
     render 'shared/edit_info', {type: 'media_object', field: field, value: @media_object[field], row_id: @media_object.id, can_edit: can_edit}
  end
    
  def media_object_redactor_helper(can_edit = false)
      render 'shared/content', {type: 'media_object', field: "content", content: @media_object.content, row_id: @media_object.id, has_content: !@media_object.content.blank?, can_edit: can_edit}
  end  
  
  def media_object_thumbnail_helper(mo)
    img_size = '100x100'
    icon_size = '50x50'
    if mo.media_type == 'image'
      image_tag(mo.src, :size => img_size)
    elsif mo.media_type == 'text'
      image_tag('mime-icons/text.png', :size => icon_size)
    elsif mo.media_type == 'pdf'
      image_tag('mime-icons/pdf.png', :size => icon_size)
    else
      image_tag('mime-icons/document.png', :size => icon_size)
    end
  end
  
end