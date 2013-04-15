# == Schema Information
#
# Table name: amazon_orders
#
#  id                  :integer          not null, primary key
#  amazon_order_id     :string(255)
#  purchase_date       :datetime
#  fulfillment_channel :string(255)
#  product_name        :string(255)
#  sku                 :string(255)
#  asin                :string(255)
#  quantity            :integer
#  item_price          :decimal(8, 2)
#  ship_postal_code    :string(255)
#  ship_country        :string(255)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

module BookCultureLib

  class AmazonOrder < ActiveRecord::Base

    validates :amazon_order_id, presence: true, uniqueness: true
    validates :purchase_date, presence: true
    validates :fulfillment_channel, presence: true
    validates :product_name, presence: true
    validates :sku, presence: true
    validates :asin, length: { maximum: 10 }
    validates :quantity, presence: true, numericality: { only_integer: true }
    validates :item_price, presence: true
    #validates :ship_postal_code, presence: true
    #validates :ship_country, presence: true

    validate :purchase_date_is_valid_datetime

    default_scope order('purchase_date ASC')

    private

    def purchase_date_is_valid_datetime
      if !purchase_date.is_a?(Date)
        errors.add(:purchase_date, 'must be a valid date') 
      end
    end

  end

end

