module Mixpanelable
  module ControllerAdditions
    include ActiveSupport::Concern

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

    def set_mixpanelable_request_uuid
      Thread.current[:mixpanelable_request_uuid] = SecureRandom.uuid
      yield
    ensure
      Thread.current[:mixpanelable_request_uuid] = nil
    end

    def set_mixpanelable_guest_uuid
      Thread.current[:mixpanelable_guest_uuid] = mixpanelable_guest_uuid
      yield
    ensure
      Thread.current[:mixpanelable_guest_uuid] = nil
    end

    def mixpanelable_guest_uuid
      cookies[:mixpanelable_guest_uuid] ||= { value: SecureRandom.uuid, expires: Time.now + (60*60*24*30) }
      cookies[:mixpanelable_guest_uuid]
    end
  end
end