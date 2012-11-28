require 'spec_helper'

class Person
  def id
    1
  end
end

class User
  def id
    1
  end
end

describe Mixpanelable::EventBuilder do
  describe "#distinct_id" do
    context "when the event is tied to an active record" do
      it "should return an id based on the model and record id" do
        active_record = Person.new
        event_builder = Mixpanelable::EventBuilder.new(active_record: active_record)

        event_builder.distinct_id.should == 'Person - 1'
      end
    end

    context "when the event is tied to the current user" do
      it "should return an id based on the user model and user id" do
        begin
          Thread.current[:mixpanelable_current_user] = User.new
          event_builder = Mixpanelable::EventBuilder.new

          event_builder.distinct_id.should == 'User - 1'
        ensure
          Thread.current[:mixpanelable_current_user] = nil
        end
      end
    end

    context "when the event is tied to the request" do
      it "should return the uuid associated with the request" do
        begin
          # Thread a current user to ensure the proper id is returned
          # even in this case.
          Thread.current[:mixpanelable_current_user] = User.new

          Thread.current[:mixpanelable_request_uuid] = 'a uuid'
          event_builder = Mixpanelable::EventBuilder.new(unique_to_request: true)

          event_builder.distinct_id.should == 'a uuid'
        ensure
          Thread.current[:mixpanelable_current_user] = nil
          Thread.current[:mixpanelable_request_uuid] = nil
        end
      end
    end

    context "when the event is not tied to anyone or anything" do
      it "should return the guest's uuid as saved in the current thread" do
        begin
          Thread.current[:mixpanelable_guest_uuid] = 'a uuid'
          event_builder = Mixpanelable::EventBuilder.new

          event_builder.distinct_id.should == 'a uuid'
        ensure
          Thread.current[:mixpanelable_guest_uuid] = nil
        end
      end
    end
  end
end