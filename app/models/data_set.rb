class DataSet < ActiveRecord::Base
  include ActionView::Helpers::SanitizeHelper

  serialize :data, JSON

  validates_presence_of :project_id, :user_id, :title

  validates_uniqueness_of :title, message: "\"%{value}\" is taken.", scope: [:project_id]

  validates :title, length: { maximum: 128 }

  has_many :media_objects

  belongs_to :project
  belongs_to :user

  alias_attribute :name, :title
  alias_attribute :owner, :user

  before_validation :sanitize_data_set

  after_create :update_project

  def update_project
    proj = Project.find(project_id)
    proj.update_attributes(updated_at: Time.now)
  end

  def sanitize_data_set
    self.title = sanitize title, tags: %w()
  end

  def self.search(search)
    regex = /^[0-9]+$/
    res = if search =~ regex
            where(
              '(data_sets.id = ?)', search.to_i)
          elsif search
            where('title LIKE ?', "%#{search}%").order('created_at DESC')
          else
            all.order('created_at DESC')
          end

    res
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
      data: data
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

    tmp_file.write(fields.map(&:name).join(',') + "\n")

    data.each do |datapoint|
      tmp_file.write(fields.map { |f| datapoint["#{f.id}"] }.join(',') + "\n")
    end

    tmp_file.close

    fname
  end

  def data_as_csv_string
    project = Project.find(project_id)
    fields = project.fields
    dstring = ''
    data.each do |datapoint|
      dstring += (fields.map { |f| datapoint["#{f.id}"] }.join(',') + "\n")
    end

    dstring
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
