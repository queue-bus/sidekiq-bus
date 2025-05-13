# frozen_string_literal: true

require 'spec_helper'
require 'sidekiq/scheduled'

describe 'Sidekiq Integration' do
  describe 'Happy Path' do
    before(:each) do
      Sidekiq::Testing.fake!
      QueueBus.dispatch('r1') do
        subscribe 'event_name' do |attributes|
          QueueBus::Runner1.run(attributes)
        end
      end

      QueueBus::TaskManager.new(false).subscribe!
    end

    it 'should publish and receive' do
      Sidekiq::Testing.fake!
      expect(QueueBus::Runner1.value).to eq(0)

      QueueBus.publish('event_name', 'ok' => true)
      expect(QueueBus::Runner1.value).to eq(0)

      QueueBus::Worker.perform_one

      expect(QueueBus::Runner1.value).to eq(0)

      QueueBus::Worker.perform_one

      expect(QueueBus::Runner1.value).to eq(1)
    end

    it 'should publish and receive' do
      Sidekiq::Testing.inline!
      expect(QueueBus::Runner1.value).to eq(0)

      QueueBus.publish('event_name', 'ok' => true)
      expect(QueueBus::Runner1.value).to eq(1)
    end
  end

  describe 'Delayed Publishing' do
    before(:each) do
      Timecop.freeze(now)
      allow(QueueBus).to receive(:generate_uuid).and_return('idfhlkj')
    end
    after(:each) do
      Timecop.return
    end
    let(:delayed_attrs) do
      { 'bus_delayed_until' => future.to_i,
        'bus_id' => "#{now.to_i}-idfhlkj",
        'bus_app_hostname' =>  Socket.gethostname }
    end

    let(:bus_attrs) { delayed_attrs.merge('bus_published_at' => worktime.to_i) }
    let(:now)    { Time.parse('01/01/2013 5:00') }
    let(:future) { Time.at(now.to_i + 60) }
    let(:worktime) { Time.at(future.to_i + 1) }

    it 'should add it to Redis' do
      hash = { :one => 1, 'two' => 'here', 'id' => 12 }
      event_name = 'event_name'
      QueueBus.publish_at(future, event_name, hash)

      val = QueueBus.redis { |redis| redis.zrange('schedule', 0, 1) }.first

      hash = JSON.parse(val)

      expect(hash['class']).to eq('QueueBus::Worker')
      expect(hash['args'].size).to eq(1)
      expect(JSON.parse(hash['args'].first)).to eq({ 'bus_class_proxy' => 'QueueBus::Publisher', 'bus_event_type' => 'event_name', 'two' => 'here', 'one' => 1, 'id' => 12 }.merge(delayed_attrs))
      expect(hash['queue']).to eq('bus_incoming')
    end

    it 'should move it to the real queue when processing' do
      hash = { :one => 1, 'two' => 'here', 'id' => 12 }
      event_name = 'event_name'

      val = QueueBus.redis { |redis| redis.lpop('queue:bus_incoming') }
      expect(val).to eq(nil)

      QueueBus.publish_at(future, event_name, hash)

      val = QueueBus.redis { |redis| redis.lpop('queue:bus_incoming') }
      expect(val).to eq(nil) # nothing really added

      Sidekiq::Scheduled::Poller.new.enqueue

      val = QueueBus.redis { |redis| redis.lpop('queue:bus_incoming') }
      expect(val).to eq(nil) # nothing added yet

      # process scheduler in future
      Timecop.freeze(worktime) do
        Sidekiq::Scheduled::Poller.new.enqueue

        val = QueueBus.redis { |redis| redis.lpop('queue:bus_incoming') }
        hash = JSON.parse(val)
        expect(hash['class']).to eq('QueueBus::Worker')
        expect(hash['args'].size).to eq(1)
        expect(JSON.parse(hash['args'].first)).to eq({ 'bus_class_proxy' => 'QueueBus::Publisher', 'bus_event_type' => 'event_name', 'two' => 'here', 'one' => 1, 'id' => 12 }.merge(delayed_attrs))

        QueueBus::Publisher.perform(JSON.parse(hash['args'].first))

        val = QueueBus.redis { |redis| redis.lpop('queue:bus_incoming') }
        hash = JSON.parse(val)
        expect(hash['class']).to eq('QueueBus::Worker')
        expect(hash['args'].size).to eq(1)
        expect(JSON.parse(hash['args'].first)).to eq({ 'bus_class_proxy' => 'QueueBus::Driver', 'bus_event_type' => 'event_name', 'two' => 'here', 'one' => 1, 'id' => 12 }.merge(bus_attrs))
      end
    end
  end
end
