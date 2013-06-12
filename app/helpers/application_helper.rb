module ApplicationHelper
  
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
  
  # Begin permissions stuff
  def can_edit? (obj)
    case obj
    when User
      (obj.id == @cur_user.try(:id)) || @cur_user.try(:admin)
    when Project, DataSet, Visualization, Tutorial
      (obj.owner.id == @cur_user.try(:id)) || cur_user.try(:admin)
    else
      false
    end
  end
  
  def can_hide? (obj)
    case obj
    when DataSet
      (obj.owner.id == @cur_user.try(:id)) || @cur_user.try(:admin) || (obj.project.owner.id == @cur_user.try(:id))
    when Project, Visualization, Tutorial
      (obj.owner.id == @cur_user.try(:id)) || cur_user.try(:admin)
    else
      false
    end
  end
  
  def can_delete? (obj)
    case obj
    when User, Project, Tutorial
      cur_user.try(:admin)
    when Dataset, Visualization, MediaObject
      (obj.owner.id == @cur_user.try(:id)) || @cur_user.try(:admin)
    else
      false
    end
  end
  
  def can_admin? (obj)
      @cur_user.try(:admin)
    end
  
  # Helper method for seperating hashes.
  # Removes the keys from hs that are in ls and returns them in a new hash
  class Hash
    def extract_keys! (ls)
      res = self.select do |k, v|
        ls.include?(k)
      end

      self.keep_if do |k, v|
        not ls.include?(k)
      end
      res
    end
  end
  
  # Generate a gravatar url of the given size for the given user
  def gravatar_url (user, size = 150)
    hash = Digest::MD5.hexdigest(user.email.downcase)
    "http://gravatar.com/avatar/#{hash}.png?s=#{size}"
  end
end
