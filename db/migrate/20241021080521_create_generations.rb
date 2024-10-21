class CreateGenerations < ActiveRecord::Migration[7.2]
  def change
    create_table :generations do |t|
      t.references :board, null: false, foreign_key: true
      t.text :state, null: false
      t.integer :step, null: false

      t.timestamps
    end
  end
end
