# frozen_string_literal: true

# require 'sidekiq_bus/tasks'
# will give you these tasks

require 'queue_bus/tasks'

namespace :queuebus do
  # Preload app files if this is Rails
  task :preload do
    require 'sidekiq'
  end
end
