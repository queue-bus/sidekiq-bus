require "queue-bus"
require "sidekiq_bus/adapter"
require "sidekiq_bus/version"

QueueBus.adapter = QueueBus::Adapters::Sidekiq.new
