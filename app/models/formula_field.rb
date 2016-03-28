include ApplicationHelper
class FormulaField < ActiveRecord::Base
  after_initialize :default_values
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
      refname: refname,
      formula: formula,
      index: index
    }

    if recurse
      h.merge!(project: project.to_hash(false))
    end

    h
  end

  def default_values
    self.name ||= Field.get_next_name project, field_type
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

  def unique_name
    return if project.nil? or name.nil?
    hits = @project.fields.where 'UPPER(name) = ?', name.upcase
    unless hits.empty?
      errors.add :base, "#{name} has the same name as another field"
    end
  end

  def self.try_execute(formulas, fields)
    # formulas: array of arrays of 4 strings
    #   the first should be the reference name of the formula field
    #   the second should be the type of the formula field
    #   the third should be its formula
    #   the fourth should be the name of the formula field
    # fields: array of arrays of 2 strings
    #   the first should be the refname of the field
    #   the second should be the type of the field

    # formulas that have been already ran
    visited_formulas = []
    # list of error messages
    errors = []

    # check all formulas
    formulas.each do |x|
      # add this formula to the array of visited formulas
      # this should be done before the formula is validated because formulas can reference
      #   themselves
      visited_formulas.push x

      # create a hash of fields, their types, validated formula fields, and their types
      field_hash = { '*' => :number }
      fields.each { |field| field_hash[field[0]] = field[1] }
      visited_formulas.each { |field| field_hash[field[0]] = field[1] }

      # construct a dummy environment from that hash
      dummy_env = Beaker.generate_dummy_env Beaker.stdlib, true, nil, field_hash

      # check the current formula
      begin
        # lex, parse and test evaluate the formula
        lex = Beaker::Lexer.lex(x[2])
        parse = Beaker::Parser.parse(x[2], lex)
        res = parse.evaluate(dummy_env)

        # determine what type we expect to receive
        expects = x[1].is_a?(Array) ? x[1][0] : x[1]

        # type mismatch
        unless res.type == :nothing or res.type == expects or (res.type == :array  and res.contains == expects)
          # if we have an array, get the value contained in the array
          type = res.type == :array ? res.contains : res.type
          # add this error message to the list of errors
          errors.push "With formula field #{x[3]}: returned type #{type}, expected type #{x[1]}"
        end
      rescue Beaker::ParseError => e
        # special case for the ParseError because it has some pretty-print stuff
        errors.push "With formula field #{x[3]}: #{e.msg[/[^\n]+/]}"
      rescue => e
        # if at any point we get an error, catch it and dump it to the list of errors
        errors.push "With formula field #{x[3]}: #{e}"
      end
    end

    errors
  end
end
