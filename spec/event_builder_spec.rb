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

    context "when the event is not tied to an active record and a current user exists" do
      it "should return an id based on the user model and user id" do
        Thread.current[:mixpanelable_current_user] = User.new
        event_builder = Mixpanelable::EventBuilder.new

        event_builder.distinct_id.should == 'User - 1'
      end
    end

    context "when the event cannot be tied to a user or active record" do
      it "should return the guest's uuid as saved in the current thread" do
        Thread.current[:mixpanelable_guest_uuid] = 'a uuid'
        event_builder = Mixpanelable::EventBuilder.new

        event_builder.distinct_id.should == 'a uuid'
      end
    end
  end
end