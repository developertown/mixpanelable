require 'mixpanelable/bots'
require 'mixpanelable/event'
require 'mixpanelable/event_builder'
require 'mixpanelable/config'
require 'mixpanelable/tracker_methods'
require 'mixpanelable/controller_additions'

require 'securerandom'

if defined?(ActionController) and defined?(ActionController::Base)
  ActionController::Base.class_eval do
    include Mixpanelable::ControllerAdditions
    
    around_filter :set_mixpanelable_current_user
    around_filter :set_mixpanelable_guest_uuid
    around_filter :set_mixpanelable_user_agent
    around_filter :set_mixpanelable_request_uuid
  end
end