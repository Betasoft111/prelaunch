class Refers < ActiveRecord::Base
  attr_accessible :refer_by, :userid
  validates :userid, :uniqueness => true
end
