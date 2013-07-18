module MediaObjectsHelper
  
  def media_object_edit_menu_helper(make_link = false)
    
    url = if !@media_object.project_id.nil?
      project_url @media_object.project
    elsif !@media_object.data_set_id.nil?
      project_url @media_object.data_set.project
    elsif !@media_object.tutorial.nil?
      tutorial_url @media_object.tutorial
    elsif !@media_object.visualization.nil?
      visualization_url @media_object.visualization
    else
      home_url
    end
    
    render 'shared/edit_menu', {type: 'media_object', typeName: 'Media Object', obj: @media_object, make_link: make_link, escape_link: url}
  end
  
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