class CreateProtocolRelationships < ActiveRecord::Migration[4.2]
  def change
    create_table :protocol_relationships do |t|
      t.references :protocol, index: true, foreign_key: true, null: false
      t.references :protocol_relationship_object, polymorphic: true, null: false
      t.integer :position, null: false
      t.integer :created_by_id, null: false
      t.integer :updated_by_id, null: false
      t.references :project, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
