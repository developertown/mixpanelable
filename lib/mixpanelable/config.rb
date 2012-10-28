require 'mixpanelable/adapters/abstract_adapter'
require 'mixpanelable/adapters/resque_adapter'

module Mixpanelable
  class Config
    cattr_accessor :token

    class << self
      def adapter
        @adapter || Adapters::ResqueAdapter
      end
      
      def adapter=(adapter_type)
        @adapter = case adapter_type
        when :resque
          Adapters::ResqueAdapter
        else
          Adapters::ResqueAdapter
        end
      end
    end
  end
end