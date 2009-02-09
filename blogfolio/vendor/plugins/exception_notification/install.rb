puts "Copying error pages..."
begin
  FileUtils.cp Dir.glob(PLUGIN_ROOT + '/error_pages/*'), RAILS_ROOT + '/app/views/shared'
  puts "The default error pages have been copied to your project's /app/views/shared directory.  Don't forget to customize them."
rescue
  puts "The default error pages failed to copy.  Please copy them manually from your project's /vendor/plugins/exception_notification/error_pages directory to /app/views/shared.  Don't forget to customize them."
end