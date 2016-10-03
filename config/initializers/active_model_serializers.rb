ActiveModel::Serializer.config.adapter = ActiveModelSerializers::Adapter::JsonApi
ActiveModelSerializers.config.include_data_default = :false

ActiveSupport.on_load(:action_controller) do
  require 'active_model_serializers/register_jsonapi_renderer'
end
