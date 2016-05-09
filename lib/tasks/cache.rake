namespace :cache do
  desc "Update cached API responses for admin dashboard"
  task :update => :environment do
    StatusCacheJob.perform_later
    puts "Cache update for status page has been queued."
  end

  task :default => :update
end
