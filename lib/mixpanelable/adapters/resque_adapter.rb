module Mixpanelable
  module Adapters
    class ResqueAdapter < AbstractAdapter
      class << self
        def send_event(event)
          Resque.enqueue(Mixpanelable::Adapters::ResqueWorker, event.name, event.properties)
        end
      end
    end

    class ResqueWorker
      @queue = :mixpanelable_event_tracker

      def self.perform(event, properties)
        params = {"event" => event, "properties" => properties}
        data = Base64.strict_encode64(JSON.generate(params))
        request = "http://api.mixpanel.com/track/?data=#{data}"

        `curl -s '#{request}'`
      end
    end
  end
end