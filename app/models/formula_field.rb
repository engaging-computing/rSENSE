include ApplicationHelper
class FormulaField < ActiveRecord::Base
  after_initialize :default_values
  before_validation :choose_refname
  validates_presence_of :project_id, :field_type, :name
  validates_uniqueness_of :name, scope: :project_id, case_sensitive: false
  validates_uniqueness_of :refname, scope: :project_id, case_sensitive: false
  validate :validate_values

  belongs_to :project
  serialize :restrictions, JSON
  alias_attribute :owner, :project

  default_scope { order('field_type ASC, created_at ASC') }

  def to_hash(recurse = true)
    h = {
      id: id,
      name: name,
      type: field_type,
      unit: unit
    }

    if recurse
      h.merge!(project: project.to_hash(false))
    end

    h
  end

  def self.get_next_name(project, field_type)
    if project.nil? or field_type.nil?
      return
    end

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

  def default_values
    self.name ||= Field.get_next_name project, field_type
  end

  def choose_refname
    parent = Project.find_by_id(project_id)
    other_refnames = []
    unless parent.nil?
      parent.fields.find_each do |f|
        other_refnames << f.refname
      end
      parent.formula_fields.find_each do |f|
        other_refnames << f.refname
      end
    end

    base_refname = name.gsub(/[^0-9A-Za-z]/, '').camelize :lower
    next_refname = base_refname
    name_count = 1
    while other_refnames.include? next_refname
      next_refname = "#{base_refname}#{name_count}"
      name_count += 1
    end

    self.refname = next_refname
  end

  def validate_values
    if !field_type.nil? and ![2, 3].include? field_type
      errors.add :field_type, 'must be either 2 (number) or 3 (text)'
    end

    unless project_id.nil?
      @project = Project.find_by_id(project_id)
      if project.nil?
        errors.add :project, 'not found'
      end
    end
  end
end
