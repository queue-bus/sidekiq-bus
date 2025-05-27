# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.0] - 2025-05-13

### Changed
- [Development] Target supported Ruby version 3.2.6

### Fixed
- Modifies allowed Sidekiq versions to allow Sidekiq 6 upgrade. 1.0.0 made the requisite code changes but did not modify the gemspec properly.

## [1.0.0] - 2025-05-13

### Changed
- [BREAKING] Updated sidekiq-scheduler to 4.0.3. This adds support for Redis 5 and Sidekiq 6, but removes support for Redis < 4.2 and Sidekiq < 4.X. The dropped versions are long out of support; please use this release to facilitate an update.

## [0.9.0] - 2019-12-03

### Added
- Tab in sidekiq web ui for bus info

### [0.8.2] - 2019-08-06

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
