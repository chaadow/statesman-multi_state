# Statesman::MultiState
![Build](https://github.com/chaadow/statesman-multi_state/actions/workflows/ruby.yml/badge.svg)

Handle multi state for `statesman` through `has_one_state_machine` ActiveRecord macro

## Usage

After you generate your transition classes as well as your state machines, all
you need to add is this in your model:

```ruby
class MyActiveRecordModel < ActiveRecord::Base
  has_one_state_machine :state, state_machine_klass: 'StateMachineKlass', transition_klass: 'MyTransitionKlass'
end
```

It also plugs into `ActiveRecord::Reflection` apis, so you can go fancy with
dynamic form generation
```ruby
  MyActiveRecordModel.reflect_on_all_state_machines
  MyActiveRecordModel.reflect_on_state_machine(:state)
```

## Installation
Add this line to your application's Gemfile:

```ruby
gem "statesman-multi_state"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install statesman-multi_state
```

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
