class AddMoreFields < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :active, :boolean
    add_column :orders, :priority, :integer
    add_column :orders, :delivery, :integer
    add_column :orders, :ordered_at, :datetime
  end
end
