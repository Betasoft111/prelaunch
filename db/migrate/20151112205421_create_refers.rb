class CreateRefers < ActiveRecord::Migration
  def change
    create_table :refers do |t|
      t.integer :userid
      t.integer :refer_by

      t.timestamps
    end
  end
end
