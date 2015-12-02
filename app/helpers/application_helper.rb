module ApplicationHelper
  def content_helper(obj)
    render 'shared/content', obj: obj
  end

  def title_and_edit_menu(obj)
    name = obj.class.to_s.split('_').map(&:capitalize).join(' ')
    render('shared/title_and_menu', obj: obj, typeName: name,
           edit: can_edit?(obj))
  end

  def get_field_name(field)
    if field == 1
      'Timestamp'
    elsif field == 2
      'Number'
    elsif field == 3
      'Text'
    elsif field == 5
      'Longitude'
    elsif field == 4
      'Latitude'
    else
      'invalid input: try get_field_type(int)'
    end
  end

  def get_field_type(field)
    if field == 'Timestamp'
      1
    elsif field == 'Number'
      2
    elsif field == 'Text'
      3
    elsif field == 'Longitude'
      5
    elsif field == 'Latitude'
      4
    else
      'invalid input: try get_field_name(string)'
    end
  end

  def has_key?(proj)
    proj && session[:contrib_access].to_i == proj.id
  end

  def key?(proj)
    proj && session[:contrib_access].to_i == proj.id
  end

  def key_name(proj, key)
    dkey = key.nil? ? nil : key.downcase
    first_key = ContribKey.where('project_id=? AND lower(key)=?', proj, dkey).first
    if first_key.nil?
      nil
    else
      first_key.name
    end
  end

  # Begin permissions stuff
  def can_edit?(obj)
    Rails.logger.error "----In can_edit?----"
    return false if current_user.nil? && session.try(:key)
    Rails.logger.error "Has key or user"
    return true  if current_user.try(:admin)
    Rails.logger.error "not admin"
    return false if obj.nil?
    Rails.logger.error "not nil"

    case obj
    when DataSet
      Rails.logger.error obj.key
      Rails.logger.error session[:key]
      obj.owner.id == current_user.try(:id) || obj.key == session[:key]
    when User
      obj.id == current_user.try(:id)
    when Project, Visualization, MediaObject
      obj.try(:owner).try(:id) == current_user.try(:id)
    when Field
      obj.try(:owner).try(:owner).try(:id) == current_user.try(:id)
    else
      false
    end
  end

  def can_hide?(obj)
    if current_user.nil?
      return false
    end

    case obj
    when Project, Tutorial
      if obj.owner.nil?
        return false
      end
      (obj.owner.id == current_user.try(:id)) || current_user.try(:admin)
    else
      false
    end
  end

  def can_delete?(obj)
    if current_user.nil?
      return false
    end

    case obj
    when Project
      (current_user.try(:admin) || obj.owner == current_user) &&
        obj.data_sets.count == 0
    when User, Tutorial, News
      current_user.try(:admin)
    when DataSet, Visualization
      (obj.owner.id == current_user.try(:id)) || current_user.try(:admin)
    when MediaObject
      (obj.owner.id == current_user.try(:id)) || current_user.try(:admin)
    when Field
      (obj.owner.owner.id == current_user.try(:id)) || current_user.try(:admin)
    else
      false
    end
  end

  def can_admin?(_obj)
    if current_user.nil?
      return false
    end

    current_user.try(:admin)
  end

  def render_title
    if @namespace[:controller] == 'projects' and params.key?(:id)
      # viewing a project
      Project.find(params[:id]).name.capitalize.html_safe
    elsif @namespace[:controller] == 'visualizations' and params.key?(:id)
      if @namespace[:action] == 'displayVis'
        # viewing data sets
        if @datasets.count == 1
          # viewing a single data set
          @datasets[0].title
        else
          # viewing multiple data sets
          'Multiple Data Sets'
        end
      else
        # viewing a saved vis
        Visualization.find(params[:id]).name.capitalize.html_safe
      end
    elsif @namespace[:controller] == 'data_sets' and @namespace[:action] == 'manualEntry'
      'Manual Entry'
    elsif @namespace[:controller] == 'data_sets' and @namespace[:action] == 'edit'
      'Editing a Data Set'
    else
      @namespace[:controller].capitalize.html_safe
    end
  end

  def is_admin?
    unless current_user.nil?
      if current_user.admin == true
        return true
      end
    end
    false
  end
end
