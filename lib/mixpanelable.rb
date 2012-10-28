require 'mixpanelable/event'
require 'mixpanelable/event_builder'
require 'mixpanelable/config'
require 'mixpanelable/tracker_methods'

require 'securerandom'

if defined?(ActionController) and defined?(ActionController::Base)
  ActionController::Base.class_eval do
    around_filter :set_mixpanable_current_user
    around_filter :set_mixpanable_guest_uuid

  private

    def set_mixpanable_current_user
      Thread.current[:mixpanelable_current_user] = current_user
      yield
    ensure
      Thread.current[:mixpanelable_current_user] = nil
    end

    def set_mixpanable_guest_uuid
      Thread.current[:mixpanelable_guest_uuid] = mixpanable_guest_uuid
      yield
    ensure
      Thread.current[:mixpanelable_guest_uuid] = nil
    end

    def mixpanable_guest_uuid
      cookies[:mixpanelable_guest_uuid] ||= { value: SecureRandom.uuid, expires: 1.year.from_now }
    end
  end
end