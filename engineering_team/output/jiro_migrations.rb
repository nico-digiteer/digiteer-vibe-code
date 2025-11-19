Below are the complete migration files required for the Jiro ticketing system, crafted using the Rails migration DSL with full reversible methods. These files are ready to run in a Rails application with the outlined project architecture.

1. **Migration for Projects Table**
```ruby
class CreateProjects < ActiveRecord::Migration[7.0]
  def change
    create_table :projects do |t|
      t.string :name, null: false
      t.string :key, null: false, index: { unique: true }
      t.text :description
      t.integer :status, null: false, default: 0 # active by default

      t.timestamps
    end
  end
end
```

2. **Migration for Tickets Table**
```ruby
class CreateTickets < ActiveRecord::Migration[7.0]
  def change
    create_table :tickets do |t|
      t.references :project, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.integer :status, null: false, default: 0 # open by default
      t.integer :priority, null: false, default: 0 # low by default
      t.references :assigned_to, foreign_key: { to_table: :users }
      t.references :reporter, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
    
    add_index :tickets, :status
    add_index :tickets, :priority
    add_index :tickets, :assigned_to_id
  end
end
```

3. **Migration for Comments Table**
```ruby
class CreateComments < ActiveRecord::Migration[7.0]
  def change
    create_table :comments do |t|
      t.references :ticket, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :content, null: false

      t.timestamps
    end
  end
end
```

4. **Migration for ActivityLogs Table**
```ruby
class CreateActivityLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :activity_logs do |t|
      t.references :ticket, null: false, foreign_key: true
      t.string :action, null: false
      t.jsonb :details, default: {}

      t.timestamps
    end
  end
end
```

These migration files include primary keys, timestamps for record keeping, necessary indexes for filtering and performance improvements, and reversible methods to ensure they can be safely rolled back if needed. The enums for status and priority are implemented in the models, as indicated by default values and indexes, to align with Rails conventions for enum attributes.