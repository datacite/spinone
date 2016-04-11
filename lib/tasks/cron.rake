namespace :cron do
  desc 'Hourly cron task'
  task :hourly do
    Rake::Task["cache:update"].invoke
    Rake::Task["cache:update"].reenable

    agents = Agent.descendants.map { |a| a.new }.select { |agent| agent.stale? }
    Rake::Task["queue:stale"].invoke(*agents.map { |agent| agent.name })
    Rake::Task["queue:stale"].reenable

    Rake::Task["sidekiq:monitor"].invoke
    Rake::Task["sidekiq:monitor"].reenable
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
