class CreateEmployees < ActiveRecord::Migration[7.0]
  def change
    create_table :employees do |t|
      t.string :state, index: { unique: true }
      t.integer :permanent
      t.integer :contract
      t.integer :permanent_male
      t.integer :permanent_female
      t.integer :contract_male
      t.integer :contract_female
      t.integer :overall_workforce
      t.string :male_female_ratio
      t.timestamps
    end
  end
end
