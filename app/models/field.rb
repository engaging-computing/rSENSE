include ApplicationHelper
class Field < ActiveRecord::Base
  validates_presence_of :project_id, :field_type, :name
  validates_uniqueness_of :name, scope: :project_id, case_sensitive: false
  validate :validate_restrictions
  belongs_to :project
  serialize :restrictions, JSON
  alias_attribute :owner, :project

  before_validation :trim_restrictions

  default_scope { order('field_type ASC, created_at ASC') }

  def to_hash(recurse = true)
    h = {
      id: id,
      name: name,
      type: field_type,
      unit: unit,
      restrictions: restrictions
    }

    if recurse
      h.merge!(project: project.to_hash(false))
    end

    h
  end

  def self.get_next_name(project, field_type)
    highest = 0
    base = get_field_name(field_type)
    project.fields.where('field_type = ?', field_type).each do |f|
      fname = f.name.split('_')
      if fname[0] == base
        if fname[1].nil?
          highest += 1
        else
          tmp = fname[1].to_i
          if tmp > highest
            highest = tmp
          end
        end
      end
    end
    if highest > 0
      name = "#{base}_#{highest + 1}"
    else
      name = base
    end
    name
  end

  def self.verify_params(params)
    if !params.key? 'field_type'
      fail 'No field type given'
    else
      unless ['1', '2', '3', '4', '5'].include?(params['field_type'].to_s)
        fail 'Bad field type given'
      end
    end

    if !params.key? 'project_id'
      fail 'No project id given'
    else
      @project = Project.find_by_id(params['project_id']) || nil
      if @project.nil?
        fail 'Project not found'
      end
    end
  end

  def trim_restrictions
    if restrictions.is_a? String
      split_r = restrictions.split ','
      self.restrictions = split_r
    end

    if restrictions.is_a? Array
      restrictions.map! { |x| x.strip }
    end
  end

  def validate_restrictions
    if not restrictions.is_a? Array
      errors[:base] << 'Field restrictions are not in a list format'
    elsif not restrictions.reduce(true) { |a, e| a and e.is_a? String }
      errors[:base] << 'Not all field restrictions are strings'
    end
  end
end
