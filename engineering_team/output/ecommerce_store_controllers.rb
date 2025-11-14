```ruby
# app/controllers/products_controller.rb
class ProductsController < ApplicationController
  before_action :set_product, only: [:show]

  def index
    @products = if params[:search]
                  Product.search(params[:search])
                else
                  Product.all
                end
  end
  
  def show
  end

  private

  def set_product
    @product = Product.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: 'Product not found'
  end
end

# app/controllers/carts_controller.rb
class CartsController < ApplicationController
  before_action :set_cart

  def show
  end

  private

  def set_cart
    @cart = current_cart
  end
end

# app/controllers/line_items_controller.rb
class LineItemsController < ApplicationController
  before_action :set_cart
  before_action :set_line_item, only: [:update, :destroy]

  def create
    product = Product.find(params[:product_id])
    @line_item = @cart.line_items.build(product: product, quantity: line_item_params[:quantity])

    if @line_item.save
      redirect_to cart_path, notice: 'Product added to cart'
    else
      redirect_to product, alert: 'Unable to add product'
    end
  end

  def update
    if @line_item.update(line_item_params)
      redirect_to cart_path, notice: 'Item updated'
    else
      redirect_to cart_path, alert: 'Unable to update item'
    end
  end

  def destroy
    @line_item.destroy
    redirect_to cart_path, notice: 'Item removed from cart'
  end

  private

  def set_cart
    @cart = current_cart
  end

  def set_line_item
    @line_item = @cart.line_items.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to cart_path, alert: 'Item not found'
  end

  def line_item_params
    params.require(:line_item).permit(:quantity)
  end
end

# app/controllers/orders_controller.rb
class OrdersController < ApplicationController
  before_action :set_cart, only: [:new, :create]
  before_action :ensure_cart_not_empty, only: [:new, :create]

  def new
    @order = Order.new
  end

  def create
    @order = Order.new(order_params)
    if @order.save
      @cart.line_items.each do |item|
        @order.order_items.create(product: item.product, price: item.product.price, quantity: item.quantity)
      end
      @order.calculate_total
      @order.save
      redirect_to order_path(@order), notice: 'Order placed successfully'
    else
      render :new, alert: 'Error placing order'
    end
  end

  def show
    @order = Order.find(params[:id])
  end

  private
  
  def set_cart
    @cart = current_cart
  end

  def ensure_cart_not_empty
    redirect_to root_path, alert: 'Your cart is empty' if @cart.line_items.empty?
  end

  def order_params
    params.require(:order).permit(:name, :email, :address)
  end
end

# app/controllers/admin/products_controller.rb
module Admin
  class ProductsController < ApplicationController
    before_action :set_product, only: [:edit, :update, :destroy]

    def index
      @products = Product.all
    end

    def new
      @product = Product.new
    end

    def create
      @product = Product.new(product_params)
      if @product.save
        redirect_to admin_products_path, notice: 'Product created successfully'
      else
        render :new, alert: 'Error creating product'
      end
    end

    def edit
    end

    def update
      if @product.update(product_params)
        redirect_to admin_products_path, notice: 'Product updated successfully'
      else
        render :edit, alert: 'Error updating product'
      end
    end

    def destroy
      @product.destroy
      redirect_to admin_products_path, notice: 'Product deleted successfully'
    end

    private

    def set_product
      @product = Product.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to admin_products_path, alert: 'Product not found'
    end

    def product_params
      params.require(:product).permit(:name, :description, :price, :image_url, :category_id)
    end
  end
end

# app/controllers/admin/orders_controller.rb
module Admin
  class OrdersController < ApplicationController

    def index
      @orders = Order.all
    end
  end
end
```

And then for the routes configuration as specified:

```ruby
# config/routes.rb
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

Together, these controller implementations, routes, and specified logic set up a simple yet functional e-commerce platform fulfilling all the required tasks and criteria outlined.