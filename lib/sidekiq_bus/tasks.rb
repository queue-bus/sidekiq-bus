# require 'sidekiq_bus/tasks'
# will give you these tasks

namespace :sidekiqbus do

  desc "Setup will configure a resque task to run before resque:work"
  task :setup => [ :preload ] do

    if ENV['QUEUES'].nil?
      manager = ::QueueBus::TaskManager.new(true)
      queues = manager.queue_names
      ENV['QUEUES'] = queues.join(",")
    else
      queues = ENV['QUEUES'].split(",")
    end

    if queues.size == 1
      puts "  >>  Working Queue : #{queues.first}"
    else
      puts "  >>  Working Queues: #{queues.join(", ")}"
    end
  end

  desc "Subscribes this application to QueueBus events"
  task :subscribe => [ :preload ] do
    manager = ::QueueBus::TaskManager.new(true)
    count = manager.subscribe!
    raise "No subscriptions created" if count == 0
  end

  desc "Unsubscribes this application from QueueBus events"
  task :unsubscribe => [ :preload ] do
    require 'resque-bus'
    manager = ::QueueBus::TaskManager.new(true)
    count = manager.unsubscribe!
    puts "No subscriptions unsubscribed" if count == 0
  end

  desc "Sets the queue to work the driver  Use: `rake sidekiqbus:driver resque:work`"
  task :driver => [ :preload ] do
    ENV['QUEUES'] = ::QueueBus.incoming_queue
  end

  # Preload app files if this is Rails
  task :preload do
    require "sidekiq"
  end


  # examples to test out the system
  namespace :example do
    desc "Publishes events to example applications"
    task :publish => [ "sidekiqbus:preload", "sidekiqbus:setup" ] do
      which = ["one", "two", "three", "other"][rand(4)]
      QueueBus.publish("event_#{which}", { "rand" => rand(99999)})
      QueueBus.publish("event_all", { "rand" => rand(99999)})
      QueueBus.publish("none_subscribed", { "rand" => rand(99999)})
      puts "published event_#{which}, event_all, none_subscribed"
    end

    desc "Sets up an example config"
    task :register => [ "sidekiqbus:preload"] do
      QueueBus.dispatch("example") do
        subscribe "event_one" do
          puts "event1 happened"
        end

        subscribe "event_two" do
          puts "event2 happened"
        end

        high "event_three" do
          puts "event3 happened (high)"
        end

        low "event_.*" do |attributes|
          puts "LOG ALL: #{attributes.inspect}"
        end
      end
    end

    desc "Subscribes this application to QueueBus example events"
    task :subscribe => [ :register, "sidekiqbus:subscribe" ]

    desc "Start a QueueBus example worker"
    task :work => [ :register, "sidekiqbus:setup", "resque:work" ]

    desc "Start a QueueBus example worker"
    task :driver => [ :register, "sidekiqbus:driver", "resque:work" ]
  end
end
