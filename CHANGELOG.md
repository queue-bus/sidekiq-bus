# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed
- Schedule now uses cron format to schedule heartbeat. The "every: 1min" format was causing multiple heartbeats to fire in the same minute if there were multiple sidekiq processes with the dynamic setting turned off (which is default).

### [0.8.1] - 2019-08-05

### Fixed
- Schedule is now setup correctly for dyanmic schedules and non-dynamic

## [0.8.0] - 2019-07-31

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
