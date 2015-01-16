require 'spec_helper'

describe "Retry" do
  class RetryTest1
    include QueueBus::Subscriber
    application :my_thing
    subscribe :event_sub
    def event_sub(attributes)
      QueueBus::Runner1.run(attributes)
    end
  end

  it "should have the methods" do
    ::QueueBus::Rider.methods.should include(:on_failure_aaa)
    ::RetryTest1.methods.should include(:on_failure_aaa)
  end

  # it "should retry failed riders"

  describe "Failed Jobs" do
    before(:each) do
      QueueBus.enqueue_to("testing", "::QueueBus::Rider", { "bus_rider_app_key" => "r2", "bus_rider_sub_key" => "event_name", "bus_event_type" => "event_name", "ok" => true, "bus_rider_queue" => "testing" })

      @worker = Resque::Worker.new(:testing)
      @worker.register_worker
    end

    it "should put it in the failed jobs" do

      QueueBus.dispatch("r2") do
        subscribe "event_name" do |attributes|
          raise "boo!"
        end
      end

      perform_next_job @worker
      Resque.info[:processed].should == 1
      Resque.info[:failed].should == 1
      Resque.info[:pending].should == 1 # requeued

      perform_next_job @worker
      Resque.info[:processed].should == 2
      Resque.info[:failed].should == 2
      Resque.info[:pending].should == 0
    end
  end
end
