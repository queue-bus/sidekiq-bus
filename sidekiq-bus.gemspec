# -*- encoding: utf-8 -*-
# stub: sidekiq-bus 0.5.8.rc ruby lib

Gem::Specification.new do |s|
  s.name = "sidekiq-bus".freeze
  s.version = "0.5.8.rc"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Brian Leonard".freeze]
  s.date = "2018-04-24"
  s.description = "A simple event bus on top of Sidekiq. Publish and subscribe to events as they occur through a queue.".freeze
  s.email = ["brian@bleonard.com".freeze]
  s.files = [".gitignore".freeze, ".rbenv-version".freeze, ".rspec".freeze, ".ruby-gemset".freeze, ".ruby-version".freeze, "Gemfile".freeze, "MIT-LICENSE".freeze, "README.mdown".freeze, "Rakefile".freeze, "lib/sidekiq-bus.rb".freeze, "lib/sidekiq_bus/adapter.rb".freeze, "lib/sidekiq_bus/middleware/retry.rb".freeze, "lib/sidekiq_bus/tasks.rb".freeze, "lib/sidekiq_bus/version.rb".freeze, "sidekiq-bus.gemspec".freeze, "spec/adapter/integration_spec.rb".freeze, "spec/adapter/support.rb".freeze, "spec/adapter_spec.rb".freeze, "spec/application_spec.rb".freeze, "spec/config_spec.rb".freeze, "spec/dispatch_spec.rb".freeze, "spec/driver_spec.rb".freeze, "spec/heartbeat_spec.rb".freeze, "spec/integration_spec.rb".freeze, "spec/matcher_spec.rb".freeze, "spec/publish_spec.rb".freeze, "spec/publisher_spec.rb".freeze, "spec/rider_spec.rb".freeze, "spec/spec_helper.rb".freeze, "spec/subscriber_spec.rb".freeze, "spec/subscription_list_spec.rb".freeze, "spec/subscription_spec.rb".freeze, "spec/worker_spec.rb".freeze]
  s.homepage = "https://github.com/queue-bus/sidekiq-bus".freeze
  s.rubyforge_project = "sidekiq-bus".freeze
  s.rubygems_version = "2.5.2".freeze
  s.summary = "A simple event bus on top of Sidekiq".freeze
  s.test_files = ["spec/adapter/integration_spec.rb".freeze, "spec/adapter/support.rb".freeze, "spec/adapter_spec.rb".freeze, "spec/application_spec.rb".freeze, "spec/config_spec.rb".freeze, "spec/dispatch_spec.rb".freeze, "spec/driver_spec.rb".freeze, "spec/heartbeat_spec.rb".freeze, "spec/integration_spec.rb".freeze, "spec/matcher_spec.rb".freeze, "spec/publish_spec.rb".freeze, "spec/publisher_spec.rb".freeze, "spec/rider_spec.rb".freeze, "spec/spec_helper.rb".freeze, "spec/subscriber_spec.rb".freeze, "spec/subscription_list_spec.rb".freeze, "spec/subscription_spec.rb".freeze, "spec/worker_spec.rb".freeze]

  s.installed_by_version = "2.5.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<queue-bus>.freeze, ["= 0.5.8"])
      s.add_runtime_dependency(%q<sidekiq>.freeze, ["<= 5.0", ">= 3.0.0"])
      s.add_development_dependency(%q<rspec>.freeze, [">= 0"])
      s.add_development_dependency(%q<fakeredis>.freeze, [">= 0"])
      s.add_development_dependency(%q<redis-namespace>.freeze, [">= 0"])
      s.add_development_dependency(%q<pry>.freeze, [">= 0"])
      s.add_development_dependency(%q<timecop>.freeze, [">= 0"])
      s.add_development_dependency(%q<json_pure>.freeze, [">= 0"])
    else
      s.add_dependency(%q<queue-bus>.freeze, ["= 0.5.8"])
      s.add_dependency(%q<sidekiq>.freeze, ["<= 5.0", ">= 3.0.0"])
      s.add_dependency(%q<rspec>.freeze, [">= 0"])
      s.add_dependency(%q<fakeredis>.freeze, [">= 0"])
      s.add_dependency(%q<redis-namespace>.freeze, [">= 0"])
      s.add_dependency(%q<pry>.freeze, [">= 0"])
      s.add_dependency(%q<timecop>.freeze, [">= 0"])
      s.add_dependency(%q<json_pure>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<queue-bus>.freeze, ["= 0.5.8"])
    s.add_dependency(%q<sidekiq>.freeze, ["<= 5.0", ">= 3.0.0"])
    s.add_dependency(%q<rspec>.freeze, [">= 0"])
    s.add_dependency(%q<fakeredis>.freeze, [">= 0"])
    s.add_dependency(%q<redis-namespace>.freeze, [">= 0"])
    s.add_dependency(%q<pry>.freeze, [">= 0"])
    s.add_dependency(%q<timecop>.freeze, [">= 0"])
    s.add_dependency(%q<json_pure>.freeze, [">= 0"])
  end
end
