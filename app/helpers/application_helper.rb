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
  
  # Begin permissions stuff
  def can_edit? (obj)
    
    if @cur_user.nil?
      return false
    end
    
    case obj
    when User
      (obj.id == @cur_user.try(:id)) || @cur_user.try(:admin)
    when Project, DataSet, Visualization, Tutorial, MediaObject
      (obj.owner.id == @cur_user.try(:id)) || @cur_user.try(:admin)
    when Field
      (obj.owner.owner == @cur_user.try(:id)) || @cur_user.try(:admin)
    else
      false
    end
  end
  
  def can_hide? (obj)
    
    if @cur_user.nil?
      return false
    end
    
    case obj
    when DataSet
      (obj.owner.id == @cur_user.try(:id)) || @cur_user.try(:admin) || (obj.project.owner.id == @cur_user.try(:id))
    when Project, Visualization, Tutorial
      (obj.owner.id == @cur_user.try(:id)) || @cur_user.try(:admin)
    else
      false
    end
  end
  
  def can_delete? (obj)
    
    if @cur_user.nil?
      return false
    end
    
    case obj
    when User, Project, Tutorial
      @cur_user.try(:admin)
    when DataSet, Visualization, MediaObject
      (obj.owner.id == @cur_user.try(:id)) || @cur_user.try(:admin)
    when Field
      (obj.owner.owner.id == @cur_user.try(:id)) || @cur_user.try(:admin)
    else
      false
    end
  end
  
  def can_admin? (obj)
    
    if @cur_user.nil?
      return false
    end
    
    @cur_user.try(:admin)
  end
end