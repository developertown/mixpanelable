module Mixpanelable
  class EventBuilder
    attr_reader :active_record, :name, :properties

    def initialize(args = {})
      @active_record = args[:active_record]
      @name = args[:name]
      @properties = args[:properties]
      self
    end

    def event
      Event.new(distinct_id: distinct_id, token: token, name: name, properties: properties)
    end

    def distinct_id
      case
      when active_record.present?
        distinct_id_for(active_record)
      when current_user.present?
        distinct_id_for(current_user)
      else
        guest_uuid
      end
    end

  private

    # There's no explicit requirement that `active_record` inherits from ActiveRecord::Base.
    # The only real requirement is an id method.
    def distinct_id_for(active_record)
      "#{active_record.class.name} - #{active_record.id}"
    end

    def current_user
      Thread.current[:mixpanelable_current_user]
    end

    def guest_uuid
      Thread.current[:mixpanelable_guest_uuid]
    end

    def token
      Config.token
    end
  end
end