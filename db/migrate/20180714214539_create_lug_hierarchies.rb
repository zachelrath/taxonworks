class CreateLugHierarchies < ActiveRecord::Migration[5.1]
  def change
    create_table :lug_hierarchies, id: false do |t|
      t.integer :ancestor_id, null: false
      t.integer :descendant_id, null: false
      t.integer :generations, null: false
    end

    add_index :lug_hierarchies, [:ancestor_id, :descendant_id, :generations],
      unique: true,
      name: "lug_anc_desc_idx"

    add_index :lug_hierarchies, [:descendant_id],
      name: "lug_desc_idx"
  end
end
