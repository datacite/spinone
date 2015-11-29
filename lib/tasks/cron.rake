namespace :cron do
  desc 'Hourly cron task'
  task :hourly do
    Rake::Task["sidekiq:monitor"].invoke
    Rake::Task["sidekiq:monitor"].reenable

    agents = Agent.descendants.map { |a| a.new }.select { |agent| agent.stale? }
    Rake::Task["queue:all"].invoke(*agents.map { |agent| agent.name })
    Rake::Task["queue:all"].reenable
  end

  desc 'Daily cron task'
  task :daily do
    Rake::Task["sidekiq:monitor"].invoke
    Rake::Task["sidekiq:monitor"].reenable
  end

  desc 'Weekly cron task'
  task :weekly do
  end

  desc 'Monthly cron task'
  task :monthly do
  end
end
