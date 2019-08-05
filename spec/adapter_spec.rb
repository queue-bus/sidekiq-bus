# frozen_string_literal: true

require 'spec_helper'

describe 'adapter is set' do
  it "should call it's enabled! method on init" do
    QueueBus.send(:reset)
    expect_any_instance_of(adapter_under_test_class).to receive(:enabled!)
    adapter_under_test_class.new
    QueueBus.send(:reset)
  end

  it 'should be defaulting to Data from spec_helper' do
    expect(QueueBus.adapter.is_a?(adapter_under_test_class)).to eq(true)
  end

  describe '.setup_heartbeat!' do
    let(:config) { spy('Sidekiq') }

    around do |example|
      begin
        old = Sidekiq.options[:lifecycle_events][:startup]
        Sidekiq.options[:lifecycle_events][:startup] = []
        example.run
      ensure
        Sidekiq.options[:lifecycle_events][:startup] = old
      end
    end

    before do
      # This configuration must think it's running on the server.
      allow(Sidekiq).to receive(:server?).and_return(true)

      # Turn on heartbeats
      QueueBus.heartbeat!

      # Need to have the schedule loaded before we load anything new
      Sidekiq::Scheduler.instance.load_schedule!
    end

    shared_examples 'a scheduled heartbeat' do
      it 'has the schedule for every minute' do
        expect(Sidekiq.get_schedule('sidekiqbus_heartbeat')['every']).to eq '1min'
      end

      it 'has scheduled the queue bus worker' do
        expect(Sidekiq.get_schedule('sidekiqbus_heartbeat')['class'])
          .to eq ::QueueBus::Worker.name
      end

      it 'will run the heartbeat proxy' do
        expect(Sidekiq.get_schedule('sidekiqbus_heartbeat')['args'])
          .to eq [{ bus_class_proxy: 'QueueBus::Heartbeat' }.to_json]
      end

      it 'will enqueue to bus_incoming' do
        expect(Sidekiq.get_schedule('sidekiqbus_heartbeat')['queue'])
          .to eq 'bus_incoming'
      end
    end

    context 'when dynamic' do
      before do
        allow(Sidekiq::Scheduler.instance).to receive(:dynamic).and_return(true)

        # Simulate running startup events
        Sidekiq.options[:lifecycle_events][:startup].each(&:call)
      end

      it_behaves_like 'a scheduled heartbeat'
    end

    context 'when non-dynamic' do
      before do
        allow(Sidekiq::Scheduler.instance).to receive(:dynamic).and_return(false)

        # Simulate running startup events
        Sidekiq.options[:lifecycle_events][:startup].each(&:call)
      end

      it_behaves_like 'a scheduled heartbeat'
    end
  end
end
