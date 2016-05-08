class Api::V1::CallbacksController < Api::BaseController
  before_filter :authenticate_user_from_token!
  load_and_authorize_resource :agent, parent: false

  def create
    deposit = params.fetch('deposit', {})
    id = deposit.fetch('id', nil)
    source_token = deposit.fetch('source_token', nil)
    state = deposit.fetch('state', nil)
    total = deposit.fetch('total', 1)
    agent = Agent.where(uuid: source_token).first

    if agent.nil?
      render json: { errors: [{ status: 400, title: "No agent found" }] }
    elsif state == "done"
      agent.update_count(total)
      render json: { deposit: { 'id' => id,
                                'type' => 'agent',
                                'attributes' => {
                                  'state' => 'done',
                                  'source_token' => agent.uuid }}}
    elsif state == "failed"
      if ENV['RAILS_ENV'] != "test" && ENV['BUGSNAG_JS_KEY']
        notif.add_tab(:callback, result)
        Bugsnag.notify(Net::HTTPBadRequest.new("Processing of deposit #{id} failed"), {
          :severity => "warning",
        })
      end

      render json: { errors: [{ status: 400, title: "Processing of deposit #{id} failed" }] }
    else
      render json: { errors: [{ status: 422, title: "Request must contain state \"done\" or \"failed\"" }] }
    end
  end
end
