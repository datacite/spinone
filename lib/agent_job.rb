class AgentJob
  include Sidekiq::Worker

  def perform(klass, options)
    agent = klass.camelize.constantize.new
    agent.process_data(options)
  end
end
