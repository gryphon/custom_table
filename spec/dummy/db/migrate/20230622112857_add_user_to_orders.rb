class AddUserToOrders < ActiveRecord::Migration[7.0]
  def change
    add_reference :orders, :user
  end
end
