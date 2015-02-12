require 'base64'
require 'store_file'

class MediaObject < ActiveRecord::Base
  include ActionView::Helpers::SanitizeHelper
  include AutoHtml

  belongs_to :user
  belongs_to :project
  belongs_to :data_set
  belongs_to :tutorial
  belongs_to :visualization
  belongs_to :news, class_name: 'News', foreign_key: 'news_id'

  alias_attribute :title, :name

  validates_presence_of :media_type, :store_key
  validates :name, length: { maximum: 128 }

  validates_presence_of :name, :file

  before_validation :sanitize_media
  before_save :check_store!

  after_destroy :remove_data!

  alias_attribute :owner, :user
  alias_attribute :dataSet, :data_set

  def parent
    project || data_set || tutorial || visualization || news || user
  end

  def sanitize_media
    self.title = sanitize title, tags: %w()
  end

  def check_store!
    if store_key.nil?
      self.store_key = store_make_key
    end

    store_make_uudir!(store_key)
  end

  def file_name
    uudir = store_uudir(store_key)
    "#{uudir}/#{file}"
  end

  def tn_file_name
    uudir = store_uudir(store_key)
    "#{uudir}/tn_#{file}"
  end

  def src
    return '' if store_key.nil? || file.nil?
    uupath = store_uupath(store_key)
    ename  = URI.escape(file)
    "#{uupath}/#{ename}"
  end

  def tn_src
    return '' if store_key.nil? || file.nil?
    uupath = store_uupath(store_key)
    ename  = URI.escape(file)
    "#{uupath}/tn_#{ename}"
  end

  def to_hash(recurse = true)
    h = {
      id: id,
      mediaType: media_type,
      name: name,
      url: UrlGenerator.new.media_object_url(self),
      createdAt: created_at.strftime('%B %d, %Y'),
      src: src,
      tn_src: tn_src
    }

    if recurse
      h.merge!(owner: owner.to_hash(false))

      if try(:project_id)
        h.merge!(project: project.to_hash(false))
      end

      if try(:data_set_id)
        h.merge!(dataSet: data_set.to_hash(false))
      end

      if try(:tutorial_id)
        h.merge!(tutorial: tutorial.to_hash(false))
      end

      if try(:visualization_id)
        h.merge!(visualization: visualization.to_hash(false))
      end

      if try(:news_id)
        h.merge!(news: news.to_hash(false))
      end
    end
    h
  end

  def add_tn
    if media_type == 'image'
      # make the thumbnail
      image = MiniMagick::Image.open(file_name)
      unless file_name.include? '.svg'
        image.resize '180'
      end
      # finish up
      File.open(tn_file_name, 'wb') do |oo|
        oo.write image.to_blob
      end

      File.chmod(0644, tn_file_name)

      self.save!
    end
  end

  # Creates a deep clone of a mediaobject, including copying the underlying file
  def cloneMedia
    nmo = dup
    nmo.store_key = nil
    nmo.check_store!
    FileUtils.cp(file_name, nmo.file_name)
    nmo.add_tn
    nmo.save!
    nmo
  end

  def summernote_image(image_data, file_type, type, item_id, owner_id)
    send("#{type}=", item_id)
    unless owner_id.nil?
      self.user_id = owner_id
    end
    self.media_type = 'image'
    self.name = 'Uploaded Image ' + SecureRandom.hex[0...5] + "#{file_type}"
    self.file = name.split('.')[0] + SecureRandom.hex + '.' + name.split('.')[1]
    sanitize_media
    self.store_key = nil
    self.check_store!
    File.open("#{file_name}", 'wb+') do |f|
      f.write image_data
      f.chmod(0644)
    end
    add_tn
    self.save!
  end

  def self.create_media_objects(description, type, item_id, owner_id = nil)
    text = Nokogiri::HTML.fragment(description)
    text.search('img').each do |picture|
      if picture['src'] && picture['src'].include?('data:image')
        data = Base64.decode64(picture['src'].partition('/')[2].split('base64,')[1])
        if picture['src'].partition('/')[2].split('base64,')[0].include? 'png'
          file_type = '.png'
        elsif picture['src'].partition('/')[2].split('base64,')[0].include? 'svg'
          file_type = '.svg'
        else
          file_type = '.jpg'
        end
        summernote_mo = MediaObject.new
        summernote_mo.summernote_image(data, file_type, type, item_id, owner_id)
        picture['src'] = summernote_mo.src
      end
    end
    text.search('iframe').each do |video|
      video['allowfullscreen'] = true
    end
    text.search('a').each do |link|
      if !link['href'].nil? and link['href'].include? 'www.youtube.com'
        external_link = link['href']
        link['href'] = '#'
        link.content = external_link
      end
    end
    text = Nokogiri::HTML.fragment AutoHtml.auto_html(text) {
      youtube(autoplay: false, allowfullscreen: true)
    }
    text.to_s
  end

  private

  def remove_data!
    File.delete(file_name)
    File.delete(tn_file_name)
  rescue Errno::ENOENT
    # whatever
  end
end
