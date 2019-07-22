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
    context 'when already setup' do
      before { QueueBus.heartbeat! }

      it 'does not change schedule' do
        expect { QueueBus.heartbeat! }
          .not_to(change { Sidekiq.get_schedule('sidekiqbus_heartbeat') })
      end

      it 'has the schedule for every minute' do
        expect(Sidekiq.get_schedule('sidekiqbus_heartbeat')['every'])
          .to eq '1min'
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

    context 'when it does not exist' do
      it 'sets the schedule' do
        expect { QueueBus.heartbeat! }
          .to(change { Sidekiq.get_schedule('sidekiqbus_heartbeat') })
      end
    end
  end
end
