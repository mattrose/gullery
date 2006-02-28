class Asset < ActiveRecord::Base

  validates_presence_of :project_id, :path
  validates_associated :project

  belongs_to :project
    
  acts_as_taggable

#     Returns the full path to this asset on disk. /Users/bert/photos/pigeon.jpg
#     If you supply a custom_path, you must do it from RAILS_ROOT, i.e. public/pigeon_small.gif
#     def absolute_filepath(custom_path=nil)
#       File.expand_path(custom_path || "public/#{url}", RAILS_ROOT)
#     end
# 
#   	Called automatically when saved from HTML forms
#   	def file_field=(file_field)
#   	  file_upload_for_user(file_field, User.current_user)
#   	end
# 
#   	Call this from email receiving scripts to save in user's directory
#   	def file_upload_for_user(file_field, user)
#   		if !file_field.original_filename.blank?
#   			Make sure the directory exists for us to save into
#   			path = "/system/users/#{user.id}/assets"
#         logger.info("PATH is #{path}")
#   			FileUtils.mkdir_p(absolute_filepath("public#{path}"))
# 
#   			Create a unique filename so files aren't overwritten
#   			Format: my_file_10291029102910.pdf
#   			sanitized = sanitize_filename(file_field.original_filename)
#   			self.name ||= sanitized.gsub(/(.*)(\..*)/, '\1') # Name without extension
#   			self.url = "#{path}/" + sanitized.gsub(/(.*)(\..*)/, '\1' + Time.now.to_i.to_s + '\2')
# 
#         logger.info("self.url #{self.url}")
#         logger.info("self.absolute_filepath #{self.absolute_filepath}")
#   			File.open(self.absolute_filepath, File::CREAT|File::WRONLY) { |f| f.write(file_field.read) }
#   		end
#   		fix_file_permissions
#   	end
# 
# 
#     TODO Verify that this is happening correctly
#     def before_destroy
#   		  File.delete absolute_filepath
#     #rescue    
#   	end
# 
#     Returns the file extension, like jpg or pdf
#     def extension
#       self.url.gsub(/.*\./, '')
#     end
# 
#     Returns the http Content-Type (image/png, etc.)
#     #
#     TODO Add more types, or get from a reference
#     def file_type
#       file_types = {
#         /jpe?g/i => 'image/jpeg',
#         /png/ => 'image/png',
#         /gif/ => 'image/gif'
#       }
#       file_types.keys.each do |k|
#         if k.match(self.extension)
#           return file_types[k]
#         end
#       end
#       nil
#     end
# 
#   protected
# 
#     Fixes a 'feature' of IE where it passes the entire path instead of just the filename
#     def sanitize_filename(value)
#         get only the filename, not the whole path
#         just_filename = value.gsub(/^.*(\\|\/)/, '')
#         NOTE: File.basename doesn't work right with Windows paths on Unix
#         INCORRECT: just_filename = File.basename(value.gsub('\\\\', '/')) 
#         replace all none alphanumeric, underscore or periods with underscore
#         just_filename.gsub(/[^\w\.\-]/,'_') 
#     end
# 


end
