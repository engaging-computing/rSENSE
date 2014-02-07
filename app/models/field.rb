include ApplicationHelper
class Field < ActiveRecord::Base
  validates_presence_of :project_id, :field_type, :name
  validates_uniqueness_of :name, scope: :project_id
  belongs_to :project
  serialize :restrictions, JSON
  alias_attribute :owner, :project

  default_scope { order("field_type ASC, created_at ASC") }

  def to_hash(recurse = true)
    h = {
      id: self.id,
      name: self.name,
      type: self.field_type,
      unit: self.unit,
      restrictions: self.restrictions
    }

    if recurse
      h.merge! ({
        project: self.project.to_hash(false)
      })
    end
    h
  end
  
  def self.get_next_name(project,field_type)
    highest = 0
    base = get_field_name(field_type)
    project.fields.where('field_type = ?',field_type).each do |f|
      fname = f.name.split("_")
      if fname[0] == base
        if fname[1].nil?
          highest +=1;
        else
          tmp = fname[1].to_i
          if tmp > highest
            highest = tmp
          end
        end
      end
    end
    if highest > 0
      name = "#{base}_#{highest+1}"
    else 
      name = base
    end
    name    
  end

  def self.verify_params(params)
    if !params.has_key? "field_type"
      raise "No field type given"
    else
      if !['1','2','3','4','5'].include?(params['field_type'].to_s)
        raise "Bad field type given"
      end
    end

    if !params.has_key? 'project_id'
      raise "No project id given"
    else
      @project = Project.find_by_id(params['project_id']) || nil
      if @project == nil
        raise "Project not found"
      end
    end
      
  end
end
