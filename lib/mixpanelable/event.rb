module Mixpanelable
  class Event
    attr_reader :name

    def initialize(args)
      @distinct_id = args[:distinct_id]
      @token = args[:token]
      @name = args[:name]
      @properties = args[:properties]
    end

    def properties
      {
        'distinct_id' => @distinct_id,
        'mp_name_tag' => @distinct_id,
        'token'       => @token
      }.merge(@properties)
    end
  end
end