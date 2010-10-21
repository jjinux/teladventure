class CreateNodes < ActiveRecord::Migration
  def self.up
    create_table :nodes do |t|
      t.int :parent_id
      t.string :choice
      t.string :outcome

      t.timestamps
    end
  end

  def self.down
    drop_table :nodes
  end
end
