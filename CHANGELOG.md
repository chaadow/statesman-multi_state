# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]
## [0.2.6] - 2025-09-03
  - Fix `initial_transition` issue when the associated model is not yet
    persisted in the database, and calls the state machine in a `validate`
    block which causes an infinite loop. This should be fixed on `statesman`
    but I don't have time and the project does not seem well maintained.

## [0.2.5] - 2025-09-03
  - Add support for `initial_transition` to `has_one_state_machine`
## [0.2.2] - 2023-10-17
  - Change demodulize placement

## [0.2.1] - 2023-10-17
### Fixed
  - Handle `transition_name` with namespaces

## [0.2.0] - 2023-10-04
### Added
  - Add `transition_foreign_key` option to the `has_one_state_machine` to proxy to the `has_many :transitions` association

## [0.1.3] - 2023-03-23
### Added
  - Add virtual_atttribute_name to the `has_one_state_machine` ActiveRecord reflection
## [0.1.2] - 2023-03-22
### Added
  - Allow to override virtual attribute name for a state machine.

## [0.1.1] - 2022-10-08
### Added
  - Add unit tests
### Changed
  - Update README with complete examples
  - Update gemspec description
## [0.1.0] - 2022-10-07
  - First release
