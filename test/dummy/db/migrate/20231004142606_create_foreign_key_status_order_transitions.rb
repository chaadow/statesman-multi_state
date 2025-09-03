class CreateForeignKeyStatusOrderTransitions < ActiveRecord::Migration[7.0]
  def change
    create_table :foreign_key_status_order_transitions do |t|
      t.string :to_state, null: false
      t.string :from_state, null: true
      t.text :metadata, default: '{}'
      t.integer :sort_key, null: false
      t.integer :custom_fk_id, null: false
      t.boolean :most_recent, null: false

      # If you decide not to include an updated timestamp column in your transition
      # table, you'll need to configure the `updated_timestamp_column` setting in your
      # migration class.
      t.timestamps null: false
    end

    # Foreign keys are optional, but highly recommended
    add_foreign_key :foreign_key_status_order_transitions, :orders, column: :custom_fk_id

    add_index(:foreign_key_status_order_transitions,
              %i(custom_fk_id sort_key),
              unique: true,
              name: "index_foreign_key_status_order_transitions_parent_sort")
    add_index(:foreign_key_status_order_transitions,
              %i(custom_fk_id most_recent),
              unique: true,
              where: "most_recent",
              name: "index_foreign_key_status_order_transitions_parent_most_recent")
  end
end
