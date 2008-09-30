puts "Copying stylesheets..."
begin
  FileUtils.cp Dir.glob(PLUGIN_ROOT + '/css/*'), RAILS_ROOT + '/public/stylesheets'
  puts "The uni-form.css stylesheet has been copied to your project's /public/stylesheets directory."
rescue
  puts "The uni-form.css stylesheet failed to copy.  Please copy it manually from your project's /vendor/plugins/uniform/assets directory to /public/stylesheets."
ensure
  puts "Don't forget to include it in your application's layouts with <%= stylesheet_link_tag 'uni-form' %>."
end

puts ""

puts "Copying javascripts..."
begin
  FileUtils.cp Dir.glob(PLUGIN_ROOT + '/javascripts/*'), RAILS_ROOT + '/public/javascripts'
  puts "The uni-form.js javascript has been copied to your project's /public/javascripts directory."
rescue
  puts "The uni-form.js javascript failed to copy.  Please copy it manually from your project's /vendor/plugins/uniform/assets directory to /public/javascripts."
ensure
  puts "Don't forget to include it in your application's layouts with <%= javascript_include_tag 'uni-form' %>, or to include the JQuery javascript library as well."
end