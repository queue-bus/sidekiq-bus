# frozen_string_literal: true

module SidekiqBus
  module Middleware
    module Client
      # ensure sidekiq will retry jobs even when they are enqueued via other adapters
      class Retry
        def call(_worker_class, job, _queue, _redis_pool)
          if job['class'] == 'QueueBus::Worker'
            job['retry'] = true unless job.key?('retry')
            job['backtrace'] = true unless job.key?('backtrace')
          end
          yield
        end
     end
   end
 end
end
