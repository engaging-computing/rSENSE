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
    else
      "invalid input: try get_field_type(int)"
    end
  end

  def get_field_name (field)
    if field == 1
      "Timestamp"
    elsif field == 2
      "Number"
    elsif field == 3
      "Text"
    elsif field == 4
      "Longitude"
    elsif field == 5
      "Latitude"
    else
      "invalid input: try get_field_type(int)"
    end
  end

  def get_field_type (field)
    if field == "Timestamp"
      1
    elsif field == "Number"
      2
    elsif field == "Text"
      3
    elsif field == "Longitude"
      4
    elsif field == "Latitude"
      5
    else
      "invalid input: try get_field_name(string)"
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
