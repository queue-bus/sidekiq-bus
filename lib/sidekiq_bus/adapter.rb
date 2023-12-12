# frozen_string_literal: true

module QueueBus
  module Adapters
    # The sidekiq adapter for queue-bus. It handles enabling, enqueuing, and
    # setting up the heartbeat.
    class Sidekiq < QueueBus::Adapters::Base
      def enabled!
        # know we are using it
        require 'sidekiq'

        # this sidekiq middleware adds in the 'retry' key to the job payload so
        # we ensure sidekiq plays well with resque.
        ::Sidekiq.configure_server do |config|
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
        ::Sidekiq::Client.push('queue' => queue_name,
                               'class' => klass,
                               'args' => [hash])
      end

      def enqueue_at(epoch_seconds, queue_name, klass, hash)
        ::Sidekiq::Client.push('queue' => queue_name,
                               'class' => klass,
                               'args' => [hash],
                               'at' => epoch_seconds)
      end

      # Sets up the heartbeat to be broadcast via sidekiq. Only enable this when
      # you have disabled the resque heart beat schedule as well, as having both
      # may cause issues.
      #
      # While this will work so long as every time sidekiq boots it triggers this
      # set up. You may consider enabling dynamic schedules to keep all nodes up
      # to date if it ever changes.
      def setup_heartbeat!(queue_name)
        if defined?(::Sidekiq::Enterprise)
          ::Sidekiq.configure_server do |config|
            config.periodic do |mgr|
              mgr.register(
                '* * * * *', # Runs every minute
                ::QueueBus::Worker.name,
                args: [
                  ::QueueBus::Util.encode('bus_class_proxy' => ::QueueBus::Heartbeat.name)
                ],
                queue: queue_name
              )
            end
          end
        else
          begin
            require 'sidekiq-scheduler'
          rescue LoadError
            QueueBus.logger.error("sidekiq-scheduler must be installed!")
            raise
          end

          ::Sidekiq.configure_server do |config|
            config.on(:startup) do
              ::Sidekiq.set_schedule(
                'sidekiqbus_heartbeat',
                cron: '0 * * * * *', # Runs every minute
                class: ::QueueBus::Worker.name,
                args: [
                  ::QueueBus::Util.encode('bus_class_proxy' => ::QueueBus::Heartbeat.name)
                ],
                queue: queue_name,
                description: 'Enqueues a heart beat every minute for the queue-bus'
              )

              ::Sidekiq::Scheduler.instance.update_schedule unless ::Sidekiq::Scheduler.instance.dynamic
            end
          end
        end
      end
    end
  end
end
