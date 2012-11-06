require 'mixpanelable/bots'
require 'mixpanelable/event'
require 'mixpanelable/event_builder'
require 'mixpanelable/config'
require 'mixpanelable/tracker_methods'

require 'securerandom'

if defined?(ActionController) and defined?(ActionController::Base)
  ActionController::Base.class_eval do
    around_filter :set_mixpanelable_current_user
    around_filter :set_mixpanelable_guest_uuid
    around_filter :set_mixpanelable_user_agent

  private

    def set_mixpanelable_current_user
      Thread.current[:mixpanelable_current_user] = current_user
      yield
    ensure
      Thread.current[:mixpanelable_current_user] = nil
    end

    def set_mixpanelable_user_agent
      Thread.current[:mixpanelable_user_agent] = request.env['HTTP_USER_AGENT']
      yield
    ensure
      Thread.current[:mixpanelable_user_agent] = nil
    end

    def set_mixpanelable_guest_uuid
      Thread.current[:mixpanelable_guest_uuid] = mixpanelable_guest_uuid
      yield
    ensure
      Thread.current[:mixpanelable_guest_uuid] = nil
    end

    def mixpanelable_guest_uuid
      cookies[:mixpanelable_guest_uuid] ||= { value: SecureRandom.uuid, expires: 1.year.from_now }
      cookies[:mixpanelable_guest_uuid]
    end
  end
end