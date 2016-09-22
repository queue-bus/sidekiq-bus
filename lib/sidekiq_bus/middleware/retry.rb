module SidekiqBus
  module Middleware
    module Server
      
      # ensure sidekiq will retry jobs even when they are enqueued via other adapters
      class Retry
        def call(worker, msg, queue)
          msg['retry'] = true unless msg['retry']
          msg['backtrace'] = true unless msg['backtrace']
          yield
        end
      end

    end

    module Client
     
      # ensure sidekiq will retry jobs even when they are enqueued via other adapters
      class Retry
       def call(worker_class, job, queue, redis_pool)
         job['retry'] = Customer.current_id = true unless job['retry']
         job['backtrace'] = true unless job['backtrace']
         yield
       end
     end

   end
 end
end