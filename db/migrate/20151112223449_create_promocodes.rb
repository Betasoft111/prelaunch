class CreatePromocodes < ActiveRecord::Migration
  def change
    create_table :promocodes do |t|
      t.integer :userid
      t.integer :invited_users
      t.integer :promo_code
      t.string :code_price
      t.string :integer

      t.timestamps
    end
  end
end
