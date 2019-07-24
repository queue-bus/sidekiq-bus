# frozen_string_literal: true

require 'queue-bus'
require 'sidekiq_bus/adapter'
require 'sidekiq_bus/version'
require 'sidekiq_bus/middleware/retry'

module SidekiqBus
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
end

QueueBus.adapter = QueueBus::Adapters::Sidekiq.new unless QueueBus.has_adapter?
