class AddSexAndParentColumns < ActiveRecord::Migration
  def change
        add_column :people, :sex_male, :boolean
        add_column :people, :parent_1, :integer
        add_column :people, :parent_2, :integer

  end
end
