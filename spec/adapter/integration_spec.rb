require 'spec_helper'
require 'celluloid'
require 'sidekiq/scheduled'

describe "Resque Integration" do
  describe "Happy Path" do
    before(:each) do
      Sidekiq::Testing.fake!
      QueueBus.dispatch("r1") do
        subscribe "event_name" do |attributes|
          QueueBus::Runner1.run(attributes)
        end
      end

      QueueBus::TaskManager.new(false).subscribe!
    end

    it "should publish and receive" do
      Sidekiq::Testing.fake!
      QueueBus::Runner1.value.should == 0

      QueueBus.publish("event_name", "ok" => true)
      QueueBus::Runner1.value.should == 0

      QueueBus::Worker.perform_one

      QueueBus::Runner1.value.should == 0

      QueueBus::Worker.perform_one

      QueueBus::Runner1.value.should == 1
    end

    it "should publish and receive" do
      Sidekiq::Testing.inline!
      QueueBus::Runner1.value.should == 0

      QueueBus.publish("event_name", "ok" => true)
      QueueBus::Runner1.value.should == 1
    end

  end

  describe "Delayed Publishing" do
    before(:each) do
      Timecop.freeze(now)
      QueueBus.stub(:generate_uuid).and_return("idfhlkj")
    end
    after(:each) do
      Timecop.return
    end
    let(:delayed_attrs) { {"bus_delayed_until" => future.to_i,
                       "bus_id" => "#{now.to_i}-idfhlkj",
                       "bus_app_hostname" =>  `hostname 2>&1`.strip.sub(/.local/,'')} }

    let(:bus_attrs) { delayed_attrs.merge({"bus_published_at" => worktime.to_i})}
    let(:now)    { Time.parse("01/01/2013 5:00")}
    let(:future) { Time.at(now.to_i + 60) }
    let(:worktime) {Time.at(future.to_i + 1)}

    it "should add it to Redis" do
      hash = {:one => 1, "two" => "here", "id" => 12 }
      event_name = "event_name"
      QueueBus.publish_at(future, event_name, hash)

      val = QueueBus.redis { |redis| redis.zrange("schedule", 0, 1) }.first

      hash = JSON.parse(val)

      hash["class"].should == "QueueBus::Worker"
      hash["args"].size.should == 1
      JSON.parse(hash["args"].first).should == {"bus_class_proxy" => "QueueBus::Publisher", "bus_event_type"=>"event_name", "two"=>"here", "one"=>1, "id" => 12}.merge(delayed_attrs)
      hash["queue"].should == "bus_incoming"
    end

    it "should move it to the real queue when processing" do
      hash = {:one => 1, "two" => "here", "id" => 12 }
      event_name = "event_name"

      val = QueueBus.redis { |redis| redis.lpop("queue:bus_incoming") }
      val.should == nil

      QueueBus.publish_at(future, event_name, hash)

      val = QueueBus.redis { |redis| redis.lpop("queue:bus_incoming") }
      val.should == nil # nothing really added

      Sidekiq::Scheduled::Poller.new.poll

      val = QueueBus.redis { |redis| redis.lpop("queue:bus_incoming") }
      val.should == nil # nothing added yet

      # process scheduler in future
      Timecop.freeze(worktime) do
        Sidekiq::Scheduled::Poller.new.poll
        val = QueueBus.redis { |redis| redis.lpop("queue:bus_incoming") }
        hash = JSON.parse(val)
        hash["class"].should == "QueueBus::Worker"
        hash["args"].size.should == 1
        JSON.parse(hash["args"].first).should == {"bus_class_proxy" => "QueueBus::Publisher", "bus_event_type"=>"event_name", "two"=>"here", "one"=>1, "id" => 12}.merge(delayed_attrs)

       QueueBus::Publisher.perform(JSON.parse(hash["args"].first))

       val = QueueBus.redis { |redis| redis.lpop("queue:bus_incoming") }
       hash = JSON.parse(val)
       hash["class"].should == "QueueBus::Worker"
       hash["args"].size.should == 1
       JSON.parse(hash["args"].first).should == {"bus_class_proxy" => "QueueBus::Driver", "bus_event_type"=>"event_name", "two"=>"here", "one"=>1, "id" => 12}.merge(bus_attrs)
      end
    end

  end
end
