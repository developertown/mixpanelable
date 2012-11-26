require 'spec_helper'
require 'ostruct'

class TestController
  include Mixpanelable::ControllerAdditions
end

describe Mixpanelable::ControllerAdditions do
  before(:each) do
    @controller = TestController.new
  end

  describe "#set_mixpanelable_current_user" do
    before(:each) do
      @current_user = 'a user'
      @controller.stub(:current_user).and_return @current_user
    end

    it "should save the current_user in the thread" do
      @controller.send(:set_mixpanelable_current_user) do
        Thread.current[:mixpanelable_current_user].should == @current_user
      end
    end

    it "should unset the current_user in the thread after yielding" do
      @controller.send(:set_mixpanelable_current_user) { }

      Thread.current[:mixpanelable_current_user].should == nil
    end
  end

  describe "#set_mixpanelable_user_agent" do
    before(:each) do
      @user_agent = 'Netscape Navigator'
      @controller.stub(:request).and_return {
        OpenStruct.new(env: { 'HTTP_USER_AGENT' => @user_agent })
      }
    end

    it "should save the user agent from the request in the thread" do
      @controller.send(:set_mixpanelable_user_agent) do
        Thread.current[:mixpanelable_user_agent].should == @user_agent
      end
    end

    it "should unset the user agent in the thread after yielding" do
      @controller.send(:set_mixpanelable_user_agent) { }

      Thread.current[:mixpanelable_user_agent].should == nil
    end
  end

  describe "#set_mixpanelable_guest_uuid" do
    before(:each) do
      @controller.stub(:cookies).and_return Hash.new
    end

    context "when it is the user's first time visting the page" do
      it "should assign a new uuid to the user and save it in a cookie" do
        @controller.send(:set_mixpanelable_guest_uuid) { }

        @controller.cookies[:mixpanelable_guest_uuid].should_not == nil
      end

      it "should save the assigned uuid in the thread" do
        @controller.send(:set_mixpanelable_guest_uuid) do
          Thread.current[:mixpanelable_guest_uuid].should == @controller.cookies[:mixpanelable_guest_uuid]
        end
      end
    end

    context "when it is a repeated visit for the user" do
      it "should save in the thread the existing uuid assigned to the user" do
        @controller.cookies[:mixpanelable_guest_uuid] = 'existing uuid'

        @controller.send(:set_mixpanelable_guest_uuid) do
          Thread.current[:mixpanelable_guest_uuid].should == @controller.cookies[:mixpanelable_guest_uuid]
        end
      end
    end

    it "should unset the guest's uuid in the thread after yielding" do
      @controller.stub(:mixpanelable_guest_uuid).and_return 'some uuid'

      @controller.send(:set_mixpanelable_guest_uuid) { }

      Thread.current[:mixpanelable_guest_uuid].should == nil
    end
  end
end