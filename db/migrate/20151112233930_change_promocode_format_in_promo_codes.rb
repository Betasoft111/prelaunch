class ChangePromocodeFormatInPromoCodes < ActiveRecord::Migration
  def up

  	change_column :promocodes, :promo_code, :string
  end

  def down
  end
end
