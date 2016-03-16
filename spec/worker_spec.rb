require 'spec_helper'

module QueueBus
  describe Worker do
    it "should proxy to given class" do
      hash = {"bus_class_proxy" => "QueueBus::Driver", "ok" => true}
      QueueBus::Driver.should_receive(:perform).with(hash)
      QueueBus::Worker.perform(JSON.generate(hash))
    end

    it "should use instance" do
      hash = {"bus_class_proxy" => "QueueBus::Rider", "ok" => true}
      QueueBus::Rider.should_receive(:perform).with(hash)
      QueueBus::Worker.new.perform(JSON.generate(hash))
    end

    it "should not freak out if class not there anymore" do
      hash = {"bus_class_proxy" => "QueueBus::BadClass", "ok" => true}

      QueueBus::Worker.perform(JSON.generate(hash)).should == nil
    end

    it "should raise error if proxy raises error" do
      hash = {"bus_class_proxy" => "QueueBus::Rider", "ok" => true}
      QueueBus::Rider.should_receive(:perform).with(hash).and_raise("rider crash")
      lambda {
        QueueBus::Worker.perform(JSON.generate(hash))
      }.should raise_error("rider crash")
    end
  end
end
