class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.string :code
      t.string :name
      t.string :details

      t.timestamps
    end
  end
end
