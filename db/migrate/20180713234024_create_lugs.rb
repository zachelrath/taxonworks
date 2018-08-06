class CreateLugs < ActiveRecord::Migration[5.1]
  def change
    create_table :lugs, id: :integer do |t|
      t.text :text, null: false
      t.references :otu, index: true, type: :integer
      t.references :parent, index: true, type: :integer
      t.references :redirect, index: true, type: :integer
      t.integer :position 
      t.text :description
      t.string :label # short label/id
      t.string :external_url
      t.string :external_url_text

      t.boolean :is_public

      t.references :project, index: true, foreign_key: true, type: :integer
      t.references :created_by, type: :integer, index: {name: 'lug_created_by_id_index'}, foreign_key: {name: 'lugs_created_by_id_fk', to_table: :users}
      t.references :updated_by, type: :integer, index: {name: 'lug_updated_by_id_index'}, foreign_key: {name: 'lugs_updated_by_id_fk', to_table: :users}
      
      t.timestamps
    end
  end


end
