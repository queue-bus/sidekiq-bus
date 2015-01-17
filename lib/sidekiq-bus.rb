require "queue-bus"
require "sidekiq_bus/adapter"
require "sidekiq_bus/version"

module ResqueBus

end

QueueBus.adapter = QueueBus::Adapters::Sidekiq.new
