module Mixpanelable
  module TrackerMethods
    extend ActiveSupport::Concern

    module ClassMethods
      def track_event(name, properties = {})
        return if user_agent_is_bot?

        event = EventBuilder.new(name: name, properties: properties).event
        Mixpanelable::Config.adapter.send_event(event)
      end

      def track_event_for(active_record, name, properties = {})
        return if user_agent_is_bot?

        event = EventBuilder.new(active_record: active_record, name: name, properties: properties).event
        Mixpanelable::Config.adapter.send_event(event)
      end

      def user_agent_is_bot?
        Mixpanelable::Bots.bot?(user_agent)
      end

      def user_agent
        Thread.current[:mixpanelable_user_agent]
      end
    end

    def track_event(name, properties = {})
      self.class.track_event(name, properties)
    end

    def track_event_for(active_record, name, properties = {})
      self.class.track_event_for(active_record, name, properties)
    end
  end
end

Object.send(:include, Mixpanelable::TrackerMethods)