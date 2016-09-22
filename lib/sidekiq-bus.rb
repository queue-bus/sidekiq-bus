require "queue-bus"
require "sidekiq_bus/adapter"
require "sidekiq_bus/version"
require 'sidekiq_bus/middleware/retry'

QueueBus.adapter = QueueBus::Adapters::Sidekiq.new
