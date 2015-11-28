namespace :queue do

  desc "Queue all works"
  task :all do |_, args|
    if args.extras.empty?
      agents = Agent.descendants.map { |a| a.new }
    else
      agents = Agent.descendants.select { |a| args.extras.include?(a.to_s.downcase) }.map { |a| a.new }
    end

    if agents.empty?
      puts "No active agent found."
      exit
    end

    begin
      from_date = ENV['FROM_DATE'] ? Date.parse(ENV['FROM_DATE']).iso8601 : (Time.now.to_date - 1.day).iso8601
      until_date = ENV['UNTIL_DATE'] ? Date.parse(ENV['UNTIL_DATE']).iso8601 : Time.now.to_date.iso8601
    rescue => e
      # raises error if invalid date supplied
      puts "Error: #{e.message}"
      exit
    end
    puts "Queueing all works published from #{from_date} to #{until_date}."

    agents.each do |agent|
      count = agent.queue_jobs(from_date: from_date, until_date: until_date)
      puts "#{count} works for agent #{agent.to_s} have been queued."
    end
  end
end
