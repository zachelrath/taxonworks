class RenameContainerItemPolymorphicFields < ActiveRecord::Migration[4.2]
  def change
    rename_column :container_items, :containable_id, :contained_object_id
    rename_column :container_items, :containable_type, :contained_object_type
  end
end
