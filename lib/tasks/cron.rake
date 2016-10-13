namespace :cron do
  desc 'Hourly cron task'
  task :hourly => :environment do
    Rake::Task["queue:stale"].invoke
    Rake::Task["queue:stale"].reenable

    Rake::Task["cache:update"].invoke
    Rake::Task["cache:update"].reenable
  end

  desc 'Daily cron task'
  task :daily do
  end

  desc 'Weekly cron task'
  task :weekly do
  end

  desc 'Monthly cron task'
  task :monthly do
  end
end
