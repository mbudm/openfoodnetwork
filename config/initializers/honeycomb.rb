require "honeycomb-beeline"

Honeycomb.configure do |config|
  config.write_key = "815d13ba9df6046c32d2291c804f5a17"
  config.dataset = "open-food-network"
  config.service_name = "ofn-local"

  config.notification_events = %w[
    sql.active_record
    render_template.action_view
    render_partial.action_view
    render_collection.action_view
    process_action.action_controller
    send_file.action_controller
    send_data.action_controller
    deliver.action_mailer
  ].freeze
end