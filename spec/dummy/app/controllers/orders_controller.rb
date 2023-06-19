class OrdersController < ApplicationController

  load_and_authorize_resource :order

  # TIP: Remove show action from router and you will get editing form inline automatically

  # GET /orders
  def index
    @orders = custom_table(@orders)
    
    respond_to do |format|
      format.html
      format.xlsx
    end
    
  end

  # GET /orders/another
  def another
    @orders = custom_table(@orders, "another")
  end

  # GET /orders/actions_skip
  def actions_skip
    @orders = custom_table(@orders)
  end

  # GET /orders/skip_actions
  def actions_skip
    @orders = custom_table(@orders)
  end

  # GET /orders/skip_actions
  def actions_custom
    @orders = custom_table(@orders)
  end

  # GET /orders/skip_actions
  def actions_skip_default
    @orders = custom_table(@orders)
  end

  # GET /orders/skip_actions
  def actions_representation
    @orders = custom_table(@orders)
  end

  # GET /orders/1
  def show
  end

  # GET /orders/new
  def new
  end

  # GET /orders/1/edit
  def edit
  end

  private

    # Only allow a list of trusted parameters through.
    def order_params
      params.require(:order).permit(:code, :name, :max_weight, :max_cbm)
    end
    
end
