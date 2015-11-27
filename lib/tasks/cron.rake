namespace :cron do
  desc 'Hourly cron task'
  task :hourly => :environment do
    Rake::Task["sidekiq:monitor"].invoke
    Rake::Task["sidekiq:monitor"].reenable
  end

  desc 'Daily cron task'
  task :daily => :environment do
    Rake::Task["sidekiq:monitor"].invoke
    Rake::Task["sidekiq:monitor"].reenable
  end

  desc 'Weekly cron task'
  task :weekly => :environment do
  end

  desc 'Monthly cron task'
  task :monthly => :environment do
  end
end
