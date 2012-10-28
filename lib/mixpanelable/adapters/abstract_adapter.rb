module Mixpanelable
  module Adapters
    class AbstractAdapter
      class << self
        def send_event(event)
          false
        end
      end
    end
  end
end