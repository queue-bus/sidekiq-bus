module SidekiqBus
  module Middleware
    module Server
      
      # ensure sidekiq will retry jobs even when they are enqueued via other adapters
      class Retry
        def call(worker, msg, queue)
          msg['retry'] = true unless msg.has_key?('retry')
          msg['backtrace'] = true unless msg.has_key?('backtrace')
          yield
        end
      end

    end

    module Client
     
      # ensure sidekiq will retry jobs even when they are enqueued via other adapters
      class Retry
       def call(worker_class, job, queue, redis_pool)
         job['retry'] = true unless job.has_key?('retry')
         job['backtrace'] = true unless job.has_key?('backtrace')
         yield
       end
     end

   end
 end
end