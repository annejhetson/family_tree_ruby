class Update2People < ActiveRecord::Migration
  def change
    change_table :people do |t|
      t.rename :parent_1, :parent_1_id
      t.rename :parent_2, :parent_2_id
    end
  end
end
