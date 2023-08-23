class AddCustomTableToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :custom_table, :text
  end
end
