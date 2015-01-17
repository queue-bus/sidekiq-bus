require 'sidekiq-bus'

def reset_test_adapter
  QueueBus.send(:reset)
  QueueBus.adapter = QueueBus::Adapters::Sidekiq.new
end

def adapter_under_test_class
  QueueBus::Adapters::Sidekiq
end

def adapter_under_test_symbol
  :sidekiq
end
