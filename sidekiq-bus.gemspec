# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "sidekiq_bus/version"

Gem::Specification.new do |s|
  s.name        = "sidekiq-bus"
  s.version     = SidekiqBus::VERSION
  s.authors     = ["Brian Leonard"]
  s.email       = ["brian@bleonard.com"]
  s.homepage    = ""
  s.summary     = %q{A simple event bus on top of Resque}
  s.description = %q{A simple event bus on top of Resque. Publish and subscribe to events as they occur through a queue.}

  s.rubyforge_project = "sidekiq-bus"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('queue-bus', '0.5.0')
  s.add_dependency('sidekiq')

  s.add_development_dependency("rspec")
  s.add_development_dependency("timecop")
  s.add_development_dependency("json_pure")
end
