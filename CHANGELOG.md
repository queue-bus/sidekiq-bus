# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Adds sidekiq-scheduler as a dependency
- Sets up the schedule of heartbeats within the adapter.

## [0.7.0] - 2019-07-29

### Changed
- Increased the minimum version of queue-bus
- If the adapter is already set, will not warn instead of error.

## [0.6.1] - 2019-06-17
### Changed

 - Upper limit of sidekiq version was expanded to include all minor versions of sidekiq.
