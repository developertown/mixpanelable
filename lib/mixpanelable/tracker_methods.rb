module Mixpanelable
  module TrackerMethods
    extend ActiveSupport::Concern

    module ClassMethods
      def track_event(name, properties = {})
        event = EventBuilder.new(name: name, properties: properties).event

        Mixpanelable::Config.adapter.send_event(event)
      end

      def track_event_for(active_record, name, properties = {})
        event = EventBuilder.new(active_record: active_record, name: name, properties: properties).event

        Mixpanelable::Config.adapter.send_event(event)
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