require 'nokogiri'

class Project < ActiveRecord::Base
  include ApplicationHelper
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::SanitizeHelper

  validates_presence_of :title
  validates_presence_of :user_id

  validates :title, length: { maximum: 128 }
  before_validation :sanitize_project
  before_save :summernote_media_objects
  has_many :fields
  has_many :data_sets, -> { order('created_at desc') }
  has_many :media_objects
  has_many :likes
  has_many :visualizations
  has_many :contrib_keys

  has_one :view_count

  belongs_to :user

  alias_attribute :name, :title
  alias_attribute :owner, :user

  def sanitize_project
    self.content = sanitize content
    # Check to see if there is any valid content left
    html = Nokogiri.HTML content
    if html.text.nil? and html.at_css('img').nil? and html.css('iframe').nil?
      self.content = nil
    end

    self.title = sanitize title, tags: %w()
  end

  def self.search(search, include_hidden = false)
    regex = /^[0-9]+$/
    search_query = Project.joins(
      'LEFT OUTER JOIN "likes" ON "likes"."project_id" = "projects"."id"
      LEFT OUTER JOIN "view_counts" ON "view_counts"."project_id" = "projects"."id"'
      ).select(
      'projects.*, count(likes.id) as like_count, view_counts.count as views'
      ).group(
     'projects.id, view_counts.count')
    res =
    if search =~ regex
      search_query.where(
      '(projects.id = ?)', search.to_i)
    elsif search
      search_query.where(
     '(lower(projects.title) LIKE lower(?)) OR
     (lower(projects.content) LIKE lower(?))', "%#{search}%", "%#{search}%")
    else
      Project.joins(
        'LEFT OUTER JOIN "likes" ON "likes"."project_id" = "projects"."id"
      LEFT OUTER JOIN "view_counts" ON "view_counts"."project_id" = "projects"."id"'
      ).select(
        'projects.*, count(likes.id) as like_count, view_counts.count as views'
      ).group('projects.id, view_counts.count')
    end

    if include_hidden
      res
    else
      res.where(hidden: false)
    end
  end

  def self.only_templates(value)
    if value == true
      where(is_template: true)
    else
      all
    end
  end

  def self.only_curated(value)
    if value == true
      where(curated: true)
    else
      all
    end
  end

  def self.only_featured(value)
    if value
      where(featured: true)
    else
      all
    end
  end

  def self.has_data(value)
    if value
      all.joins(:data_sets).distinct
    else
      all
    end
  end

  def has_contrib_key?
    !contrib_keys.empty?
  end

  def add_view!
    vc = view_count
    vc = ViewCount.create(project_id: id) unless vc
    vc.count = vc.count + 1
    vc.save!
  end

  def views
    return 0 if view_count.nil?
    view_count.count
  end

  def to_hash(recurse = true)
    h = {
      id: id,
      featuredMediaId: featured_media_id,
      name: name,
      url: UrlGenerator.new.project_url(self),
      path: UrlGenerator.new.project_path(self),
      hidden: hidden,
      featured: featured,
      likeCount: likes.count,
      content: content,
      timeAgoInWords: time_ago_in_words(created_at),
      createdAt: created_at.strftime('%B %d, %Y'),
      ownerName: owner.name,
      ownerUrl: UrlGenerator.new.user_url(owner),
      dataSetCount: data_sets.count,
      fieldCount: fields.count,
      fields: fields.map { |o| o.to_hash false }
    }

    unless featured_media_id.nil?
      h.merge!(mediaSrc: media_objects.find(featured_media_id).src)
    end

    if recurse
      h.merge!(
        dataSets:     data_sets.map     { |o| o.to_hash false },
        mediaObjects: media_objects.map { |o| o.to_hash false },
        owner:        owner.to_hash(false)
      )
    end

    h
  end

  def export_concatenated(datasets)
    require 'fileutils'
    random_hex = SecureRandom.hex
    folder_name = title.parameterize
    tmpdir = "/tmp/rsense/#{random_hex}/#{folder_name}"

    begin
      FileUtils.mkdir_p(tmpdir)
      tmp_file = File.new("#{tmpdir}/#{title.gsub(' ', '_')}_selected_data_sets.csv", 'w+')
      tmp_file.write(fields.map { |f| f.name }.join(',') + "\n")
      datasets.split(',').each do |d|
        dataset = DataSet.find(d.to_i)
        tmp_file.write(dataset.data_as_csv_string)
      end
      tmp_file.close
      csv_file = "/tmp/rsense/#{random_hex}/#{folder_name}/#{title.gsub(' ', '_')}_selected_data_sets.csv"
    rescue
      raise 'Failed to export'
    end
    csv_file
  end

  def export_data_sets(datasets)
    require 'fileutils'
    random_hex = SecureRandom.hex
    folder_name = title.parameterize
    tmpdir = "/tmp/rsense/#{random_hex}/#{folder_name}"

    begin
      FileUtils.mkdir_p(tmpdir)
      datasets.split(',').each do |d|
        dataset = DataSet.find(d.to_i)
        dataset.to_csv(tmpdir)
      end
      system("(cd /tmp/rsense/#{random_hex} && zip -qr #{folder_name}.zip #{folder_name})")
      zip_file = "/tmp/rsense/#{random_hex}/#{folder_name}.zip"
    rescue
      raise 'Failed to export'
    end
    zip_file
  end

  def clone(params, user_id)
    # Create project
    new_project = Project.new
    new_project.user_id = user_id
    new_project.cloned_from = id
    new_project.content = content

    # Determine Name
    if params[:project_name].nil?
      new_project.title = "#{title} (clone)"
    else
      new_project.title = params[:project_name]
    end

    new_project.save

    # Clone fields
    field_map = {}
    fields.each do |f|
      nf = f.dup
      nf.project_id = new_project.id
      nf.save
      field_map[f.id.to_s] = nf.id.to_s
    end

    # Clone Media Objects
    media_objects.each do |mo|
      next unless mo.data_set_id.nil?

      nmo = mo.cloneMedia
      nmo.project_id = new_project.id
      nmo.user_id = user_id
      nmo.save!

      new_project.media_objects << nmo

      # Replace old the old mo's path with the new mo's path whenever it
      # occurs in the project's description
      unless content.nil?
        new_project.content.gsub! mo.src, nmo.src
      end

      if new_project.featured_media_id == mo.id
        new_project.featured_media_id = nmo.id
      end
    end

    # Save the project now that all meta data is cloned
    new_project.save

    # Clone datasets
    if params[:clone_datasets]
      data_sets.each do |ds|
        nds = ds.dup
        nds.project_id = new_project.id
        nds.user_id = user_id
        nds.created_at = ds.created_at
        # Fix data fields
        data = nds.data
        new_data = []
        data.each do |row|
          field_map.each do |old_key, new_key|
            row[new_key] = row[old_key]
            row.delete old_key
          end
          new_data.push row
        end
        nds.data = new_data
        nds.save!

        # Clone dataset media
        ds.media_objects.each do |mo|
          nmo = mo.cloneMedia
          nmo.data_set_id = nds.id
          nmo.project_id = new_project.id
          nmo.user_id = user_id

          nmo.save!
        end

        nds.save!
      end
    end

    new_project
  end

  def summernote_media_objects
    self.content = MediaObject.create_media_objects(content, 'project_id', id, user_id)
  end
end

# where filter like filters[0] AND filter like filters[1]
