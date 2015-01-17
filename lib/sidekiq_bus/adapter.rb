module QueueBus
  module Adapters
    class Sidekiq < QueueBus::Adapters::Base
      def enabled!
        # know we are using it
        require 'sidekiq'
      end

      def redis(&block)
        ::Sidekiq.redis(&block)
      end

      def enqueue(queue_name, klass, hash)
        ::Sidekiq::Client.push('queue' => queue_name, 'class' => klass, 'args' => [hash])
      end

      def enqueue_at(epoch_seconds, queue_name, klass, hash)
        ::Sidekiq::Client.push('queue' => queue_name, 'class' => klass, 'args' => [hash], 'at' => epoch_seconds)
      end

      def setup_heartbeat!(queue_name)
        # TODO: not sure how to do this or what is means to set this up in Sidekiq
        raise NotImplementedError
      end

      def worker_included(base)
        base.include ::Sidekiq::Worker
      end
    end
  end
end
