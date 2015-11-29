class StatusJob
  include Sidekiq::Worker

  def perform
    status = Status.new
    status.write
  end
end
