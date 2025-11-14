```ruby
# app/models/product.rb
class Product < ApplicationRecord
  belongs_to :category
  has_many :line_items
  has_many :order_items

  validates :name, :price, presence: true
  validates :price, numericality: { greater_than: 0 }

  scope :search, -> (query) { where('name ILIKE ?', "%#{query}%") }
end

# app/models/category.rb
class Category < ApplicationRecord
  has_many :products

  validates :name, presence: true
end

# app/models/cart.rb
class Cart < ApplicationRecord
  has_many :line_items, dependent: :destroy

  def total_price
    line_items.joins(:product).sum('line_items.quantity * products.price')
  end
end

# app/models/line_item.rb
class LineItem < ApplicationRecord
  belongs_to :product
  belongs_to :cart

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
end

# app/models/order.rb
class Order < ApplicationRecord
  has_many :order_items, dependent: :destroy

  validates :name, :email, :address, presence: true

  before_save :calculate_total

  def calculate_total
    self.total_price = order_items.sum('quantity * price')
  end
end

# app/models/order_item.rb
class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :price, numericality: { greater_than: 0 }
end
```

These model files establish the relationships, validations, and essential methods for e-commerce operations. They are aligned with Rails conventions and the specified architecture of the `ecommerce_store`. This includes product searches, validation of form inputs, the calculation of total prices in carts and orders, and proper associations necessary for the application workflows.