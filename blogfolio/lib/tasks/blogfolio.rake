namespace :blogfolio do
  desc "Clear the cached Flickr data for site responsiveness"
  task :clear_photo_cache => :environment do
    Rails.cache.delete('photos')
    Rails.cache.delete('plant_photo')
    `rm #{Rails.root}/public/*.html`
  end
end