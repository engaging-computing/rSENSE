require 'beaker'

class DataSet < ActiveRecord::Base
  include ActionView::Helpers::SanitizeHelper

  serialize :data, JSON
  serialize :formula_data, JSON

  validates_presence_of :project_id, :user_id, :title

  validates_uniqueness_of :title, message: "\"%{value}\" is taken.", scope: [:project_id]

  validates :title, length: { maximum: 128 }
  validates :count, numericality: { less_than_or_equal_to: 100000, message: 'Maximum size of a data set is 100,000.' }

  has_many :media_objects

  belongs_to :project, inverse_of: :data_sets
  belongs_to :user, counter_cache: true

  alias_attribute :name, :title
  alias_attribute :owner, :user

  before_validation :sanitize_data_set
  before_validation :recalculate
  before_validation :update_count

  after_create :update_project

  def update_project
    proj = Project.find(project_id)
    proj.update_attributes(updated_at: Time.now)
  end

  def sanitize_data_set
    self.title = strip_tags(title)

    data.each do |data_row|
      data_row.keys.each do |key|
        # Remove any and all HTML tags
        if data_row[key].is_a? String
          data_row[key] = strip_tags(data_row[key])
        end
        # replace numeric hash keys with string hash keys
        unless key.is_a? String
          data_row[key.to_s] = data_row[key]
          data_row.delete key
        end
      end
    end
  end

  def self.search(search)
    where('id = ? OR title LIKE ?', search.to_i, "%#{search}%").order('created_at DESC')
  end

  def to_hash(recurse = true)
    h = {
      id: id,
      name: title,
      ownerId: user.id,
      ownerName: user.name,
      contribKey: key,
      url: UrlGenerator.new.data_set_url(self),
      path: UrlGenerator.new.data_set_path(self),
      createdAt: created_at.strftime('%B %d, %Y'),
      fieldCount: project.fields.length,
      datapointCount: data.length,
      displayURL: "/projects/#{project.id}/data_sets/#{id}",
      data: data,
      count: count
    }

    if recurse
      fields = project.fields.map { |f| f.to_hash(false) }

      # FIXME: Dead code?
      # field_indices = {}
      # fields.each_with_index do |field, i|
      #   field_indices[field[:id].to_s] = i
      # end

      h.merge!(
        owner: owner.to_hash(false),
        project: project.to_hash(false),
        fields: fields
      )
    end

    h
  end

  def to_csv(tmpdir)
    project = Project.find(project_id)
    fields = project.fields
    fname = ("#{title.parameterize}.csv")
    tmp_file = File.new("#{tmpdir}/#{fname}", 'w+')

    tmp_file.write(fields.map { |f| (f.name.respond_to?(:include?) and f.name.include?(',')) ? '"' + f.name + '"' : f.name }.join(',') + "\n")

    data.each do |datapoint|
      tmp_file.write(fields.map { |f| (datapoint["#{f.id}"].respond_to?(:include?) and datapoint["#{f.id}"].include?(',')) ? '"' + datapoint["#{f.id}"] + '"' : datapoint["#{f.id}"] }.join(',') + "\n")
    end

    tmp_file.close

    fname
  end

  def data_as_csv_string
    project = Project.find(project_id)
    fields = project.fields
    dstring = ''
    data.each do |datapoint|
      dstring += (fields.map { |f| (datapoint["#{f.id}"].respond_to?(:include?) and datapoint["#{f.id}"].include?(',')) ? '"' + datapoint["#{f.id}"] + '"' : datapoint["#{f.id}"] }.join(',') + "\n")
    end

    dstring
  end

  def recalculate(formula_fields = nil, fields = nil)
    if formula_fields.nil?
      formula_fields = project.formula_fields
    end

    if formula_fields.length == 0
      return
    end

    if fields.nil?
      fields = project.fields
    end

    curr_env = Beaker::Environment.new(false, Beaker.stdlib)
    field_arrays = []
    formula_field_arrays = []

    # add each regular field to the environment as an array type
    fields.each do |x|
      key = x.id.to_s
      beaker_arr = case x.field_type
                   when 1
                     arr = data.map do |y|
                       begin
                         DateTime.parse(y[key])
                       rescue
                         nil
                       end
                     end
                     Beaker::ArrayType.new(arr, :timestamp, 0)
                   when 2
                     arr = data.map { |y| y[key].nil? or y[key] == '' ? nil : y[key].to_f }
                     Beaker::ArrayType.new(arr, :number, 0)
                   when 3
                     arr = data.map { |y| y[key] }
                     Beaker::ArrayType.new(arr, :text, 0)
                   when 4
                     arr = data.map { |y| y[key].to_f }
                     Beaker::ArrayType.new(arr, :latitude, 0)
                   when 5
                     arr = data.map { |y| y[key].to_f }
                     Beaker::ArrayType.new(arr, :longitude, 0)
                   else
                     arr = data.map { |y| y[key] }
                     Beaker::ArrayType.new(arr, :text, 0)
                   end
      curr_env.add x.refname, beaker_arr
      field_arrays.push(beaker_arr)
    end

    # evaluate each of the formula fields, one at a time
    formulae = formula_fields.to_a.sort { |x, y| x.index <=> y.index }
    formulae.each do |x|
      # parse the expression and get it ready to run on the data
      lex = Beaker::Lexer.lex(x.formula)
      ast = Beaker::Parser.parse(x.formula, lex)

      # create the new field so it can be referenced by itself
      new_field = Beaker::ArrayType.new([nil] * data.length, x.field_type == 2 ? :number : :text, 0)
      curr_env.add x.refname, new_field

      (0 ... data.length).each do |idx|
        # set up the environment
        pos_env = Beaker::Environment.new(false, curr_env)
        pos_env.add '*', Beaker::NumberType.new(idx)

        # update the position of each of the fields to the current position
        field_arrays.each { |field| field.curr_pos = idx }
        formula_field_arrays.each { |field| field.curr_pos = idx }
        new_field.curr_pos = idx

        eval = begin
                 # evaluate the AST with environment
                 tmp = ast.evaluate(pos_env)
                 tmp.get
               rescue Beaker::Error
                 # if anything breaks, just return nil
                 nil
               end
        # Strip HTML from result
        eval = strip_tags(eval) if eval.is_a? String
        # dump this value into the array
        new_field.value[idx] = eval
        curr_env.add x.refname, new_field
      end

      formula_field_arrays.push(new_field)
    end

    # add formula fields as data
    dset = (0 ... data.length).map do |x|
      obj = {}
      (0 ... formula_fields.length).each do |y|
        if formulae[y].field_type == 2
          obj[formulae[y].id.to_s] = Beaker::NumberType.to_s(formula_field_arrays[y].value[x])
        else
          obj[formulae[y].id.to_s] = formula_field_arrays[y].value[x]
        end
      end
      obj
    end

    self.formula_data = dset
  end

  def update_count
    self.count = data.count
  end

  def self.get_next_name(project, fname)
    highest = 0
    base = fname
    project.data_sets.each do |dset|
      title = dset.title
      if title.include? base
        highest += 1
        val = title[/\d+/].to_i || nil
        next if val.nil?
        if val.to_i > highest
          highest = val.to_i
        end
      end
    end

    highest == 0 ? fname : "#{fname}(#{highest})"
  end
end
