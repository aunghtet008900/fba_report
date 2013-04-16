class CreateAmazonOrderTable <  ActiveRecord::Migration
  def change
    create_table :amazon_orders do |t|
      t.string :amazon_order_id
      t.datetime :purchase_date
      t.string :fulfillment_channel
      t.string :product_name
      t.string :sku
      t.string :asin
      t.integer :quantity
      t.decimal :item_price, precision: 8, scale: 2
      t.string :ship_postal_code
      t.string :ship_country

      t.timestamps
    end
  end
end

### For reference: All available columns from the Amazon file:
#  :amazon_order_id
#  :merchant_order_id
#  :purchase_date
#  :last_updated_date
#  :order_status
#  :fulfillment_channel
#  :sales_channel
#  :order_channel
#  :url
#  :ship_service_level
#  :product_name
#  :sku
#  :asin
#  :item_status
#  :quantity
#  :currency
#  :item_price
#  :item_tax
#  :shipping_price
#  :shipping_tax
#  :gift_wrap_price
#  :gift_wrap_tax
#  :item_promotion_discount
#  :ship_promotion_discount
#  :ship_city
#  :ship_state
#  :ship_postal_code
#  :ship_country
#  :promotion_ids

