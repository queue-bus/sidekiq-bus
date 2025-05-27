# frozen_string_literal: true

require 'timecop'
require 'queue-bus'
require 'adapter/support'
require 'pry'

reset_test_adapter

require 'fakeredis'
Sidekiq.redis = ConnectionPool.new { Redis.new(driver: Redis::Connection::Memory) }

require 'fileutils'

# Ensuring log file exist and are ready for running specs.
log_file = File.join(__dir__, '../log/test.log')
FileUtils.mkdir_p(File.dirname(log_file))
FileUtils.touch(log_file)

logger = Logger.new(File.open(log_file, 'a'))

Sidekiq.logger = logger
QueueBus.logger = logger

require 'sidekiq/testing'

module QueueBus
  class Runner
    def self.value
      @value ||= 0
    end

    class << self
      attr_reader :attributes
    end

    def self.run(attrs)
      @value ||= 0
      @value += 1
      @attributes = attrs
    end

    def self.reset
      @value = nil
      @attributes = nil
    end
  end

  class Runner1 < Runner
  end

  class Runner2 < Runner
  end
end

class Redis
  module Connection
    class Memory
      def script(*args)
        case args[1]
        when Sidekiq::Scheduled::Enq::LUA_ZPOPBYSCORE
          QueueBus.redis do |redis|
            now = Time.now.to_f

            # Process both 'schedule' and 'retry' sets
            %w[schedule retry].each do |set_name|
              # Get jobs that are ready to be processed (score <= now)
              jobs = redis.zrangebyscore(set_name, '-inf', now)

              jobs.each do |job_json|
                # Remove from scheduled set
                redis.zrem(set_name, job_json)

                # Parse and re-enqueue the job
                job_data = JSON.parse(job_json)
                queue_name = job_data['queue'] || 'default'
                redis.lpush("queue:#{queue_name}", job_json)
              end
            end
          end
        else
          raise "NOSCRIPT - FakeRedis gem does not include Lua support. Please see spec/spec_helper.rb for more information."
        end
      end
    end
  end
end

def test_sub(event_name, queue = 'default')
  matcher = { 'bus_event_type' => event_name }
  QueueBus::Subscription.new(queue, event_name, '::QueueBus::Rider', matcher, nil)
end

def test_list(*args)
  out = QueueBus::SubscriptionList.new
  args.each do |sub|
    out.add(sub)
  end
  out
end

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run focus: true
  config.alias_example_to :fit, focus: true

  config.mock_with :rspec do |c|
    c.syntax = :expect
  end
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each) do
    reset_test_adapter
    Sidekiq::Testing.disable!
  end
  config.after(:each) do
    begin
      QueueBus.redis(&:flushall)
    rescue StandardError
    end
    QueueBus.send(:reset)
    QueueBus::Runner1.reset
    QueueBus::Runner2.reset
  end
end
