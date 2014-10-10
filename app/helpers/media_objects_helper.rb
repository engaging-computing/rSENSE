module MediaObjectsHelper
  def media_object_thumbnail_helper(mo, size = nil, download = false)
    if size.nil?
      img_size = '32x32'
    else
      img_size = size
    end

    if download == false
      if mo.media_type == 'image'
        image_tag(mo.tn_src, size: img_size)
      elsif mo.media_type == 'text'
        image_tag('mime-icons/text.png', size: img_size)
      elsif mo.media_type == 'pdf'
        image_tag('mime-icons/pdf.png', size: img_size)
      else
        image_tag('mime-icons/document.png', size: img_size)
      end
    else
      if mo.media_type == 'image'
        image_tag(mo.tn_src, size: img_size)
      elsif mo.media_type == 'text'
        image_tag('mime-icons/text-download.png', size: img_size)
      elsif mo.media_type == 'pdf'
        image_tag('mime-icons/pdf-download.png', size: img_size)
      else
        image_tag('mime-icons/document-download.png', size: img_size)
      end
    end
  end
end
