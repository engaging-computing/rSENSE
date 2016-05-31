include ApplicationHelper
class Field < ActiveRecord::Base
  include ActionView::Helpers::SanitizeHelper

  after_initialize :default_values

  before_validation :sanitize_html
  before_validation :trim_restrictions
  before_validation :choose_refname

  validates_presence_of :project_id, :field_type, :name

  validates_uniqueness_of :name, scope: :project_id, case_sensitive: false
  validates_uniqueness_of :refname, scope: :project_id, case_sensitive: false

  validate :validate_values
  validate :unique_name

  belongs_to :project
  serialize :restrictions, JSON
  alias_attribute :owner, :project

  default_scope { order('field_type ASC, created_at ASC') }

  def to_hash(recurse = true)
    h = {
      id: id,
      name: name,
      type: field_type,
      unit: unit,
      restrictions: restrictions,
      refname: refname,
      index: index
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

    base = get_field_name(field_type)
    project_fields = project.fields.where('field_type = ?', field_type)
    project_formula_fields = project.formula_fields.where('field_type = ?', field_type)
    suffixes = (project_fields + project_formula_fields).map do |f|
      fname = f.name.split('_')
      if fname[0] == base
        fname[1].nil? ? 1 : fname[1].to_i
      else
        0
      end
    end

    highest = suffixes.length == 0 ? 0 : suffixes.max
    if highest > 0
      "#{base}_#{highest + 1}"
    else
      base
    end
  end

  def default_values
    self.restrictions ||= []
    self.name ||= Field.get_next_name project, field_type
  end

  def trim_restrictions
    if restrictions.is_a? String
      split_r = restrictions.split ','
      self.restrictions = split_r
    end

    if restrictions.is_a? Array
      restrictions.map! do |x|
        if x.is_a? String
          x.strip
        else
          x
        end
      end
    end
  end

  def choose_refname
    return if refname != '' or name.nil?

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

    base_refname = name.gsub(/[^0-9A-Za-z]/, '-').split('-').map { |x| x.capitalize }.join
    next_refname = base_refname
    name_count = 1
    while other_refnames.include? next_refname
      next_refname = "#{base_refname}_#{name_count}"
      name_count += 1
    end

    self.refname = next_refname
  end

  def sanitize_html
    # Strip HTML from input
    self.name = strip_tags(name)
    self.unit = strip_tags(unit)
    self.restrictions = strip_tags(restrictions)
  end

  def validate_values
    # verify that restrictions is an array of strings
    if !restrictions.is_a? Array
      errors.add :restrictions, 'must be in an array'
    elsif !restrictions.reduce(true) { |a, e| a and (e.is_a? String or e.is_a? Numeric) }
      errors.add :restrictions, 'must all be parsable as strings'
    end

    if !field_type.nil? and ![1, 2, 3, 4, 5].include? field_type
      errors.add :field_type, 'must be a number between 1 and 5'
    end

    unless project_id.nil?
      @project = Project.find_by_id(project_id)
      if project.nil?
        errors.add :project, 'not found'
      end
    end
  end

  def unique_name
    return if project.nil? or name.nil?
    hits = @project.formula_fields.where 'UPPER(name) = ?', name.upcase
    unless hits.empty?
      errors.add :base, "#{name} has the same name as another formula field"
    end
  end
end
