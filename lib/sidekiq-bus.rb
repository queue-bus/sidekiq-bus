# frozen_string_literal: true

require 'queue-bus'
require 'sidekiq_bus/adapter'
require 'sidekiq_bus/version'
require 'sidekiq_bus/server'
require 'sidekiq_bus/middleware/retry'

module SidekiqBus
  ConfigurationError = Class.new(StandardError)
  REDIS_HANDLER_ERROR_MESSAGE = 'Please set SidekiqBus.redis_handler to a Callable that accepts a block and yields a '\
        'Redis instance. See the SidekiqBus README for more details.'

  # This method will analyze the current queues and generate an array that
  # can operate as the sidekiq queues configuration. It should be based on how
  # The sidekiq CLI builds weighted queues.
  #
  # @param overrides [Hash<String, Integer>] A mapping of queue names and
  #     weights that must be included
  # @param default [Integer] The default weight to apply to any given queue
  # @returns [Array<String>] The set of queue names weighted to sidekiq
  def self.generate_weighted_queues(overrides: {}, default: 1)
    # Gathers all queues and overrides as strictly strings
    queues = Set.new(QueueBus::TaskManager.new(false).queue_names.map(&:to_s))
    overrides = overrides.each_with_object({}) { |(q, w), h| h[q.to_s] = w }
    overrides.default = default

    # Also pitches-in for driving the bus.
    queues << 'bus_incoming'

    # Make sure every queue from the overrides is included
    queues += overrides.keys

    entry = Struct.new(:queue, :weight)

    # Map all queue names to their weights and returns them as entries
    entries = queues.map { |q| entry.new(q, [1, overrides[q]].max) }

    # Sorts by weight to provide a visual indication of queue order in sidekiq
    # UI. Otherwise they can appear in various orders. They will be sorted
    # from greatest to least weight. The negative sign on the weight is key to
    # making this work.
    entries = entries.sort_by { |e| [-e.weight, e.queue] }

    # Creates an array of N length with the same queue name (N=weight) then
    # flattened into a single array
    entries.flat_map { |e| Array.new(e.weight, e.queue) }
  end

  def self.redis_handler=(handler)
    unless handler.respond_to?(:call)
      raise ConfigurationError, REDIS_HANDLER_ERROR_MESSAGE
    end
    @redis_handler = handler
  end

  def self.redis(&block)
    raise ConfigurationError, REDIS_HANDLER_ERROR_MESSAGE unless @redis_handler
    @redis_handler.call(&block)
  end

  def self.validate_redis_handler
  end
end

if QueueBus.has_adapter?
  warn '[SidekiqBus] Not setting adapter on queue-bus because ' \
      "#{QueueBus.adapter.class.name} is already the adapter"
else
  QueueBus.adapter = QueueBus::Adapters::Sidekiq.new
end
