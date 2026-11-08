# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]
## [0.3.2] - 2026-11-08
  - Fix the initial transition never being written when the state machine was first
    read before the record was persisted (e.g. `save_with_state`, which compares the
    form state to `current_state` before saving): the machine is no longer memoized
    until the record is persisted.
  - `save_with_state` on a new record now records the initial transition before the
    transition to the submitted state (two transitions instead of one).

## [0.2.9] - 2026-02-06
  - Avoid creating initial transitions when connected to a replica (ActiveRecord `reading_role`).

## [0.2.8] - 2026-02-06
  - Reset memoized state machines on `reload` so `current_state` is not stale after
    concurrent updates.

## [0.2.7] - 2026-01-21
  - Fix `save_with_state` false negative always returning true even when the
    transition is invalid.

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
