class Photo < ActiveRecord::Base
  require 'mini_exiftool'
  
  validates_presence_of [:title, :image_date]
  
  after_save :save_image
  after_destroy :delete_image
  
  SAVE_PATH = "/media"
  
  def initialize(options = {})
    super(options)
    logger.warn("file: #{self.filename}")
    if @temp_file
      exif = MiniExiftool.new @temp_file.path
      self.image_date = exif.modifydate
      self.focal_length = exif.focallength
      self.aperture = exif.aperturevalue
      self.speed = exif.iso
      self.caption = exif.captionabstract
      self.keywords = exif.keywords
      self.shutter_speed = exif.exposuretime
      self.height = exif.imageheight
      self.width = exif.imagewidth
    end
    self
  end
  
  def image=(new_image)
    @temp_file = new_image
    self.filename = new_image.original_filename
    self.title = new_image.original_filename[0..-5]
  end
  
  def path
    "#{SAVE_PATH}/photos/#{self.filename}"
  end
  
  def thumbnail
    "#{SAVE_PATH}/thumbnails/#{self.filename}"
  end
  
  def system_path
    "#{RAILS_ROOT}/public/#{SAVE_PATH}/photos/#{self.filename}"
  end
  
  def system_thumbnail_path
    "#{RAILS_ROOT}/public/#{SAVE_PATH}/thumbnails/#{self.filename}"
  end
  
  def save_image
    if @temp_file
      FileUtils.cp @temp_file.path, self.system_path
      FileUtils.chmod 0644, self.system_path
    end
  end

  def delete_image
    File.delete(self.system_path) if File.exist?(self.system_path)
  end
end
