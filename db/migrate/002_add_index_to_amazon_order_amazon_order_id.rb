class AddIndexToAmazonOrderAmazonOrderId <  ActiveRecord::Migration
  def change
    add_index :amazon_orders, :amazon_order_id, unique: true
  end
end

