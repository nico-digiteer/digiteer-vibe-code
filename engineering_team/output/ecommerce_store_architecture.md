# Technical Specification for `ecommerce_store` Rails Application

## 1. Database Schema

### Products Table
```ruby
create_table :products do |t|
  t.string :name, null: false
  t.text :description
  t.decimal :price, precision: 10, scale: 2, null: false
  t.string :image_url
  t.references :category, foreign_key: true
  t.timestamps
end

add_index :products, :name
```

### Categories Table
```ruby
create_table :categories do |t|
  t.string :name, null: false
  t.timestamps
end

add_index :categories, :name
```

### Carts Table
```ruby
create_table :carts do |t|
  t.timestamps
end
```

### LineItems Table
```ruby
create_table :line_items do |t|
  t.references :product, foreign_key: true
  t.references :cart, foreign_key: true
  t.integer :quantity, default: 1
  t.timestamps
end
```

### Orders Table
```ruby
create_table :orders do |t|
  t.string :name, null: false
  t.string :email, null: false
  t.text :address, null: false
  t.decimal :total_price, precision: 10, scale: 2
  t.timestamps
end
```

### OrderItems Table
```ruby
create_table :order_items do |t|
  t.references :order, foreign_key: true
  t.references :product, foreign_key: true
  t.integer :quantity, default: 1
  t.decimal :price, precision: 10, scale: 2
  t.timestamps
end
```

## 2. Models

### Product Model
```ruby
class Product < ApplicationRecord
  belongs_to :category
  has_many :line_items
  has_many :order_items

  validates :name, :price, presence: true
  validates :price, numericality: { greater_than: 0 }

  scope :search, -> (query) { where('name ILIKE ?', "%#{query}%") }
end
```

### Category Model
```ruby
class Category < ApplicationRecord
  has_many :products

  validates :name, presence: true
end
```

### Cart Model
```ruby
class Cart < ApplicationRecord
  has_many :line_items, dependent: :destroy

  def total_price
    line_items.joins(:product).sum('line_items.quantity * products.price')
  end
end
```

### LineItem Model
```ruby
class LineItem < ApplicationRecord
  belongs_to :product
  belongs_to :cart

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
end
```

### Order Model
```ruby
class Order < ApplicationRecord
  has_many :order_items, dependent: :destroy

  validates :name, :email, :address, presence: true

  def calculate_total
    self.total_price = order_items.sum('quantity * price')
  end
end
```

### OrderItem Model
```ruby
class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :price, numericality: { greater_than: 0 }
end
```

## 3. Routes
```ruby
Rails.application.routes.draw do
  root 'products#index'
  
  resources :products, only: [:index, :show]
  
  resource :cart, only: [:show] do
    resources :line_items, only: [:create, :update, :destroy]
  end
  
  resources :orders, only: [:new, :create, :show]
  
  namespace :admin do
    resources :products
    resources :orders, only: [:index]
  end
end
```

## 4. Controller Structure

### ProductsController
- **index** - List products with search/filter functionality
- **show** - Display product details

### CartsController
- **show** - Display items in the cart

### LineItemsController
- **create** - Add product to cart
- **update** - Update item quantities in cart
- **destroy** - Remove item from cart

### OrdersController
- **new** - Checkout form
- **create** - Process order
- **show** - Order confirmation

### Admin::ProductsController
- **index** - List all products with options to edit or delete
- **new** - Add a new product
- **create** - Save new product
- **edit** - Edit existing product
- **update** - Update product
- **destroy** - Delete product

### Admin::OrdersController
- **index** - View all orders

### Strong Parameters Example
```ruby
# OrdersController
private

def order_params
  params.require(:order).permit(:name, :email, :address)
end
```

## 5. Service Objects
For this simple e-commerce system, service objects are not necessary as most of the logic can be handled in models and controllers. However, complex logic can be refactored into service objects as the application scales. 

Example structure:
```ruby
# app/services/order_processor.rb
class OrderProcessor
  def initialize(cart, order_params)
    @cart = cart
    @order_params = order_params
  end

  def call
    # Business logic for processing the order
  end
end
```

This comprehensive technical specification outlines the structure necessary to build a simple, scalable e-commerce application using Rails 7+, Slim templates, and Bootstrap 5.