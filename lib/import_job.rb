class ImportJob
  include Sidekiq::Worker

  def perform(klass, options)
    import = klass.constantize.new(options)
    import.process_data(options)
  end
end
