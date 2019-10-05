# frozen_string_literal: true

class SpinoneSchema < GraphQL::Schema
  include ApolloFederation::Schema
  
  use ApolloFederation::Tracing
  
  default_max_page_size 250
  max_depth 10

  # mutation(Types::MutationType)
  query(QueryType)

  use GraphQL::Batch
  use GraphQL::Cache
end

GraphQL::Errors.configure(SpinoneSchema) do
  rescue_from StandardError do |exception|
    Raven.capture_exception(exception)
    message = Rails.env.production? ? "We are sorry, but an error has occured. This problem has been logged and support has been notified. Please try again later. If the error persists please contact support." : exception.message
    GraphQL::ExecutionError.new(message)
  end

  # rescue_from CustomError do |exception, object, arguments, context|
  #   nil
  # end
end
