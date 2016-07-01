namespace :cron do
  desc 'Hourly cron task'
  task :hourly => :environment do
    Rake::Task["cache:update"].invoke
    Rake::Task["cache:update"].reenable

    unless ENV['RUNIT']
      Rake::Task["sidekiq:monitor"].invoke
      Rake::Task["sidekiq:monitor"].reenable
    end
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
