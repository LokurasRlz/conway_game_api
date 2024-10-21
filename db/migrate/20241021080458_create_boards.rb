class CreateBoards < ActiveRecord::Migration[7.2]
  def change
    create_table :boards do |t|
      t.text :initial_state, null: false
      t.integer :rows, null: false
      t.integer :cols, null: false

      t.timestamps
    end
  end
end
