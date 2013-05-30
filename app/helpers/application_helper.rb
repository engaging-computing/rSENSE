module ApplicationHelper

#   def include_page_spesific_js
#     if FileTest.exists? "app/assets/javascripts/"+params[:controller]+"/"+params[:action]+".js.coffee"
#       return '<script src="/assets/'+params[:controller]+'/'+params[:action]+'.js.coffee" type="text/javascript"></script>'
#     end
#   end
  
  def get_field_id (type)
    if type == "Time"
      1
    elsif type == "Number"
      2
    elsif type == "Location"
      3
    elsif type == "Text"
      4
    end
  end
  
  def get_field_type (id)
    if id == 1
      "Time"
    elsif id == 2
      "Number"
    elsif id == 3
      "Location"
    elsif id == 4
      "Text"
    end
  end
  
  def can_edit? (obj)
    if(obj.class == User)
      (obj.id == @cur_user.try(:id)) || @cur_user.try(:admin)
    else
      (obj.owner.id == @cur_user.try(:id)) || @cur_user.try(:admin)
    end
  end
  
  def gravatar_url (user, size = 150)
    hash = Digest::MD5.hexdigest(user.email.downcase)
    "http://gravatar.com/avatar/#{hash}.png?s=#{size}"
  end
end
