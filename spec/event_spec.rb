require 'spec_helper'

describe Mixpanelable::Event do
  describe "#properties" do
    before(:each) do
      @event = Mixpanelable::Event.new(
        distinct_id: 'a distinct id',
        token: 'a token',
        name: 'an event name',
        properties: { 'a' => 'property' }
      )
    end

    it "should include the distinct id as the 'distinct_id' property" do
      @event.properties['distinct_id'].should == 'a distinct id'
    end

    it "should include the distinct id as the 'mp_name_tag' property" do
      @event.properties['mp_name_tag'].should == 'a distinct id'
    end

    it "should include the token as the 'token' property" do
      @event.properties['token'].should == 'a token'
    end

    it "should include the other given properties" do
      @event.properties['a'].should == 'property'
    end
  end
end