# Statesman::MultiState 
![Gem](https://img.shields.io/gem/v/statesman-multi_state?style=for-the-badge) ![Build Status](https://img.shields.io/github/workflow/status/chaadow/statesman-multi_state/Ruby?style=for-the-badge)

Handle multiple state machines on the same ActiveRecord model for `statesman` through `has_one_state_machine` ActiveRecord macro.

You can generate as many state machines and transition classes as you wishes, and plug them on the same model.

The `has_one_state_machine` will generate all the necessary instance and class methods, prefixed by the state machine name.
So each state machine is isolated from each other.

ActiveRecord scope `.in_state` is also prefixed.

Finally, you can have the same state machine name on different AR models.

## Installation
Add this line to your application's Gemfile, and you should be all set. No need to include anything.

```ruby
gem "statesman-multi_state"
```

## Usage



```ruby
class Order < ActiveRecord::Base
  has_one_state_machine :business_status, state_machine_klass: 'OrderBusinessStatusStateMachine', transition_klass: 'OrderBusinessStatus'
  has_one_state_machine :admin_status, state_machine_klass: 'StateMachineKlass', transition_klass: 'MyTransitionKlass'
end
```

Calling `has_one_state_machine` on `business_status` adds the following:
- A has_many association with the transition table
```ruby
 has_many :order_business_status_transitions, dependent: :destroy
 ```
 - a virtual attribute `#business_status_state_form` (using the `ActiveRecord::Attributes` API ) to represent the actual current value of the state machine on the transition table.
 This also allows to be used in forms directly without the need for nested attributes. Using this API instead of a regular `attr_accessor` allows us to get all the benefits of dirty tracking, so we can track when changes were made, and perform the appropriate transitions.
It default to `business_status` current state on the state machine
```ruby
 attribute :order_business_state_form
 
 <% form_for @order do |f| %>
 ...
 f.select :order_business_state_form, ...
...
 <% end %>
 
 ```
 - An instance method  `#business_state_state_machine` pointing to an instance of the state machine. as well as delegating all methods to it.
 ```ruby
   def business_status_state_machine
     @business_status_state_machine ||= OrderBusinessStatusStateMachine.new(...)
     
     # Ex. Order.new.business_status_current_state
     %w[current_state in_state? transition_to transition_to! can_transition_to? history last_transition
             last_transition_to].each { delegate _1, to: :business_status_state_machine, prefix: :business_status }
   end
 ```
 - ActiveRecord scopes prefixed by the state machine field name :
 ```ruby
  Order.business_status_in_state('...')
  Order.business_status_not_in_state('...')
  
  Order.admin_status_in_state('...')
  Order.admin_status_not_in_state('...')
```
- I18n instance and class methods helpers following some convention :
```ruby
Order.business_status_human_wrapper
Order.admin_status_human_wrapper

Order.new.business_status_current_state_human
Order.new.admin_status_current_state_human
```
It expects the I18n nomenclature to be like the following having the state machine as a prefix. So for `Order` AR class, and `business_status` as a state machine name, the key should be `business_status_order`
```yml
en:
  statesman:
    business_status_order:
      user_pending: User Pending
      processed: Processed
    admin_status_order:
      admin_pending: Admin Pending
      validated: Validated
```
 
 - Finally, and most importantly, an instance method `#save_with_state(**options)` is defined that takes care of making all the necesary transitions, using the virtual attribute mentioned above and checking if the current state changed, and if so, it registers a callback, so it delays the `transition_to` call until all state machines have registered their calls. finally the AR model (Order for example), saves itself, and calls all the callbacks that take care of performing all the transitions.
 
 This is done this way because: 
 1. Transition table expects the model ( order) to exist before hand, otherwise it would raise an error saying it's missing the Order `belongs_to` association
 2. By delaying this way it handles both order creation and update, making it fully compatible with creation phase of Order as well as handling multiple state machines
 
 Here is a unit test demonstrating `save_with_state`
 ```ruby
         order = Order.new
        assert_equal :user_pending, order.user_status_current_state.to_sym
        assert_equal :admin_pending, order.admin_status_current_state.to_sym
        assert_equal 0, UserStatusOrderTransition.count
        assert_equal 0, AdminStatusOrderTransition.count

        # This is equivalent to a user selecting a state in a rails form, using the virtual attributes defined above
        order.user_status_state_form = 'processed'
        order.admin_status_state_form = 'validated'

        order.save_with_state # You should call this method from now on in your `#create` and `#update` controller actions

        assert_equal :processed, order.user_status_current_state.to_sym
        assert_equal :validated, order.admin_status_current_state.to_sym
        assert_equal 1, UserStatusOrderTransition.count
        assert_equal 1, AdminStatusOrderTransition.count
```


It also plugs into `ActiveRecord::Reflection` APis, so you can go fancy with
dynamic form generation
```ruby
  Order.state_machine_reflections # { 'business_status' => Reflection(..), 'admin_status' => Reflection(..) }
  Order.reflect_on_all_state_machines
  Order.reflect_on_state_machine(:state)
```
This is similiar to `has_one_attached` / `has_many` / `belongs_to` reflections. 

For multiple states on a model, this can allow you to generate generic partials/components, and iterate on your model dynamically based on the state machines defined on the model.
```ruby
<% order.class.state_machine_reflections.keys.each do |state| %> # ['business_status, 'admin_status']
  <%= render "my_state_machine_partial", state: state %>
<%>
```


## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
