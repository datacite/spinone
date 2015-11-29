namespace :cache do

  desc "Update status page"
  task :update do
    StatusJob.perform_async
    puts "Update for status page has been queued."
  end

  task :default => :update

end
