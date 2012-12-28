namespace :blogfolio do
  desc "Clear the cached Flickr data for site responsiveness"
  task :clear_photo_cache => :environment do
    puts "Clearing cached photos"
    Rails.cache.delete('photos')
    Rails.cache.delete('plant_photo')
    puts "Clearing cached pages"
    `rm -r #{Rails.root}/public/*.html`
  end
end