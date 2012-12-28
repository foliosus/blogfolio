puts "Copying stylesheets..."
begin
  FileUtils.cp Dir.glob(PLUGIN_ROOT + '/css/*'), RAILS_ROOT + '/public/stylesheets'
  puts "The uni-form.css stylesheet has been copied to your project's /public/stylesheets directory.  Don't forget to include it in your application's layouts with <%= stylesheet_link_tag 'uni-form' %>."
rescue
  puts "The uni-form.css stylesheet failed to copy.  Please copy it manually from your project's /vendor/plugins/uniform/assets directory to /public/stylesheets.  Don't forget to include it in your application's layouts with <%= stylesheet_link_tag 'uni-form' %>."
end