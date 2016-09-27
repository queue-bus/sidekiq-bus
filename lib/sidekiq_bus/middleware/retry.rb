module SidekiqBus
  module Middleware
    module Client
     
      # ensure sidekiq will retry jobs even when they are enqueued via other adapters
      class Retry
       def call(worker_class, job, queue, redis_pool)
         if job['class'] == 'QueueBus::Worker'
          job['retry'] = true unless job.has_key?('retry')
          job['backtrace'] = true unless job.has_key?('backtrace')
         end
         yield
       end
     end

   end
 end
end