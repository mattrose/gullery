class Asset < ActiveRecord::Base

  cattr_accessor :thumbnail_width, :thumbnail_height

  validates_presence_of :project_id, :path
  validates_associated :project

  belongs_to :project
    
  acts_as_taggable

  # Starts with '/' but is relative to 'public'
  ASSET_DIR = '/system/assets'

  @@thumbnail_width = '200'
  @@thumbnail_height = '120'

  # Returns the full path to this asset on disk. /Users/bert/photos/pigeon.jpg
  # TODO Take size argument
  def absolute_path(size=:normal)
    File.expand_path("public#{self.web_path(size)}", RAILS_ROOT)
  end

  # :thumb, :normal, :original
  def web_path(size=:normal)
    if size == :original
      return path
    else
      path.gsub /(\..*?)$/, "_#{size.to_s}\\1"
    end
  end


	# Called automatically when saved from HTML forms
	def file_field=(file_field)
		if !file_field.original_filename.blank?
			# Make sure the directory exists for us to save into
			FileUtils.mkdir_p(File.expand_path("public#{ASSET_DIR}", RAILS_ROOT))

			#self.name ||= sanitized.gsub(/(.*)(\..*)/, '\1') # Name without extension
			self.path = "#{ASSET_DIR}/" + sanitize_filename(file_field.original_filename)
			File.open(self.absolute_path, File::CREAT|File::WRONLY) { |f| f.write(file_field.read) }

      self.create_thumbnail
      self.create_normal
		end
	end


  def create_thumbnail
		image = MiniMagick::Image.from_file(self.absolute_path)
		if (image.width.to_f/image.height.to_f) >= (@@thumbnail_width.to_f/@@thumbnail_height.to_f)
      # Wider than tall...use height
      image.combine_options do |i|
        i.resize "x#{@@thumbnail_height}"
        i.crop "#{@@thumbnail_width}x#{@@thumbnail_height}+0+0!"
      end
    else
      image.combine_options do |i|
        i.resize "#{@@thumbnail_width}x"
        i.crop "#{@@thumbnail_width}x#{@@thumbnail_height}+0+0!"
      end
    end
    image.write(File.expand_path("public#{self.web_path(:thumb)}", RAILS_ROOT))
  end


  def create_normal
		image = MiniMagick::Image.from_file(self.absolute_path)
		if image.width > 640 || image.height > 480
      image.combine_options do |i|
        i.resize "640x480"
      end
    end
    image.write(File.expand_path("public#{self.web_path(:normal)}", RAILS_ROOT))
  end


  def before_destroy
    [:original, :normal, :thumb].each do |size|
		  begin
		    File.delete absolute_path(size)
	    rescue Errno::ENOENT => e
	    end
    end
	end

  # Returns the file extension, like jpg or pdf
  def extension
    self.path.gsub(/.*\./, '')
  end

  # Returns the http Content-Type (image/png, etc.)
  #
  # TODO Add more types, or get from a reference
  def file_type
    file_types = {
      /jpe?g/i => 'image/jpeg',
      /png/ => 'image/png',
      /gif/ => 'image/gif'
    }
    file_types.keys.each do |k|
      if k.match(self.extension)
        return file_types[k]
      end
    end
    nil
  end

protected

  # Fixes a 'feature' of IE where it passes the entire path instead of just the filename
  def sanitize_filename(value)
      #get only the filename, not the whole path
      just_filename = value.gsub(/^.*(\\|\/)/, '')
      #NOTE: File.basename doesn't work right with Windows paths on Unix
      #INCORRECT: just_filename = File.basename(value.gsub('\\\\', '/')) 
      #replace all none alphanumeric, underscore or periods with underscore
      just_filename.gsub(/[^\w\.\-]/,'_') 
  end

end
