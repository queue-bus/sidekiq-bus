module QueueBus
  module Adapters
    class Sidekiq < QueueBus::Adapters::Base
      def enabled!
        # know we are using it
        require 'sidekiq'

        #this sidekiq middleware adds in the 'retry' key to the job payload so we ensure sidekiq plays well with resque
        ::Sidekiq.configure_server do |config|
          config.server_middleware do |chain|
            chain.prepend ::SidekiqBus::Middleware::Server::Retry
          end
          config.client_middleware do |chain|
            chain.prepend ::SidekiqBus::Middleware::Client::Retry
          end
        end
        ::QueueBus::Worker.include ::Sidekiq::Worker
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
    end
  end
end
