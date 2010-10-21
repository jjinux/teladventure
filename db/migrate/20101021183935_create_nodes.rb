class CreateNodes < ActiveRecord::Migration
  def self.up
    create_table :nodes do |t|
      t.integer :parent_id
      t.string :choice, :null => false
      t.string :outcome, :null => false

      t.timestamps
    end

    add_index :nodes, :parent_id
    add_foreign_key :nodes, :nodes, :column => :parent_id, :dependent => :delete
  end

  def self.down
    drop_table :nodes
  end
end