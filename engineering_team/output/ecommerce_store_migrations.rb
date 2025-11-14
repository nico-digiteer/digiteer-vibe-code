To generate the database migration files for the `ecommerce_store` application, here are the complete migration contents necessary to create the database schema as per the technical specification:

### db/migrate/001_create_categories.rb
```ruby
class CreateCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :categories do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :categories, :name
  end
end
```

### db/migrate/002_create_products.rb
```ruby
class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.text :description
      t.decimal :price, precision: 10, scale: 2, null: false
      t.string :image_url
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end

    add_index :products, :name
  end
end
```

### db/migrate/003_create_carts.rb
```ruby
class CreateCarts < ActiveRecord::Migration[7.0]
  def change
    create_table :carts do |t|
      t.timestamps
    end
  end
end
```

### db/migrate/004_create_line_items.rb
```ruby
class CreateLineItems < ActiveRecord::Migration[7.0]
  def change
    create_table :line_items do |t|
      t.references :product, null: false, foreign_key: true
      t.references :cart, null: false, foreign_key: true
      t.integer :quantity, default: 1

      t.timestamps
    end
  end
end
```

### db/migrate/005_create_orders.rb
```ruby
class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.text :address, null: false
      t.decimal :total_price, precision: 10, scale: 2

      t.timestamps
    end
  end
end
```

### db/migrate/006_create_order_items.rb
```ruby
class CreateOrderItems < ActiveRecord::Migration[7.0]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :quantity, default: 1
      t.decimal :price, precision: 10, scale: 2

      t.timestamps
    end
  end
end
```

These migration files adhere to the requirements by ensuring proper naming, timestamps, indexing for performance, and foreign keys for referential integrity. They are structured to be executed sequentially and are complete with the necessary `change` methods for creating the database tables. Running `rails db:migrate` will create the necessary tables in the database.