class AddUserHouskeepingToBiologicalRelatedStuff < ActiveRecord::Migration[4.2]
  def change
    add_column :biological_associations_biological_associations_graphs, :created_by_id, :integer
    add_column :biological_associations_biological_associations_graphs, :updated_by_id, :integer
  end
end
