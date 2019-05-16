# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SidekiqBus do
  describe '.generate_weighted_queues' do
    subject { SidekiqBus.generate_weighted_queues(args) }

    let(:args) { {} }

    before do
      QueueBus.dispatch('app') do
        subscribe 'some_event' do |_|
        end
      end
    end

    it 'includes bus incoming' do
      expect(subject.count('bus_incoming')).to eq 1
    end

    it 'includes subscribed queues' do
      expect(subject.count('app_default')).to eq 1
    end

    it 'sorts alphabetical' do
      expect(subject).to eq %w[app_default bus_incoming]
    end

    context 'with overrides' do
      let(:args) do
        super().merge(overrides: { 'queue_a' => 3, 'app_default' => 5 })
      end

      it 'includes weight-copies of the queue names' do
        expect(subject.count('queue_a')).to eq 3
      end

      it 'applies the override to an existing queue' do
        expect(subject.count('app_default')).to eq 5
      end

      it 'sorts by weight' do
        expect(subject)
          .to eq %w[app_default app_default app_default app_default app_default
                    queue_a queue_a queue_a
                    bus_incoming]
      end

      context 'that are symbols' do
        let(:args) do
          super().merge(overrides: { queue_a: 3, app_default: 5 })
        end

        it 'includes weight-copies of the queue names' do
          expect(subject.count('queue_a')).to eq 3
        end

        it 'applies the override to an existing queue' do
          expect(subject.count('app_default')).to eq 5
        end

        it 'sorts by weight' do
          expect(subject)
            .to eq %w[app_default app_default app_default app_default app_default
                      queue_a queue_a queue_a
                      bus_incoming]
        end
      end

      context 'with multiple of same weight' do
        let(:args) do
          super().merge(overrides: { 'queue_a' => 2, 'app_default' => 2 })
        end

        it 'sorts alphabetical' do
          expect(subject)
            .to eq %w[app_default app_default queue_a queue_a bus_incoming]
        end
      end

      context 'when negative' do
        let(:args) do
          super().merge(overrides: { 'queue_a' => -1, 'app_default' => -1 })
        end

        it 'includes 1 of each' do
          expect(subject.count('queue_a')).to eq 1
          expect(subject.count('app_default')).to eq 1
        end
      end

      context 'and a default' do
        let(:args) { super().merge(default: 4) }

        it 'includes bus incoming' do
          expect(subject.count('bus_incoming')).to eq 4
        end

        it 'includes weight-copies of the queue names' do
          expect(subject.count('queue_a')).to eq 3
        end

        it 'applies the override to an existing queue' do
          expect(subject.count('app_default')).to eq 5
        end
      end
    end

    context 'with a default' do
      let(:args) { super().merge(default: 5) }

      it 'applies it to bus incoming' do
        expect(subject.count('bus_incoming')).to eq 5
      end

      it 'applies it to an existing queue' do
        expect(subject.count('app_default')).to eq 5
      end
    end
  end
end
