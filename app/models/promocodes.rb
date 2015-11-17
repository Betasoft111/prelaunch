class Promocodes < ActiveRecord::Base
  attr_accessible :code_price, :integer, :invited_users, :promo_code, :userid
end
