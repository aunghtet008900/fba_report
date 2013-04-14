class CreateAmazonOrderTable <  ActiveRecord::Migration
  def up
    create_table :amazon_orders do |t|
      #t.string :name
      #t.integer :salary

      t.string :amazon_order_id
      t.string :merchant_order_id
      t.string :purchase_date
      t.string :last_updated_date
      t.string :order_status
      t.string :fulfillment_channel
      t.string :sales_channel
      t.string :order_channel
      t.string :url
      t.string :ship_service_level
      t.string :product_name
      t.string :sku
      t.string :asin
      t.string :item_status
      t.string :quantity
      t.string :currency
      t.string :item_price
      t.string :item_tax
      t.string :shipping_price
      t.string :shipping_tax
      t.string :gift_wrap_price
      t.string :gift_wrap_tax
      t.string :item_promotion_discount
      t.string :ship_promotion_discount
      t.string :ship_city
      t.string :ship_state
      t.string :ship_postal_code
      t.string :ship_country
      t.string :promotion_ids

      t.timestamps
    end
  end

  def down
    drop_table :amazon_orders
  end
end

