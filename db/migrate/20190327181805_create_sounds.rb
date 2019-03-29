class CreateSounds < ActiveRecord::Migration[5.2]
  def change
    create_table :sounds do |t|

      t.integer :created_by_id, null: false, index: true
	  t.integer :updated_by_id, null: false, index: true
	  t.references :project, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
