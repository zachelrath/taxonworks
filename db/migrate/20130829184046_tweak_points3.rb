class TweakPoints3 < ActiveRecord::Migration[4.2]
  def change
    remove_columns :geographic_items, :point,
                   :line_string,
                   :polygon,
                   :multi_point,
                   :multi_line_string,
                   :multi_polygon,
                   :geometry_collection
    add_column :geographic_items, :point, :st_point, :geographic => true, :has_z => true, :has_m => false
    add_column :geographic_items, :line_string, :line_string, :geographic => true, :has_z => true, :has_m => false
    add_column :geographic_items, :polygon, :st_polygon, :geographic => true, :has_z => true, :has_m => false
    add_column :geographic_items, :multi_point, :multi_point, :geographic => true, :has_z => true, :has_m => false
    add_column :geographic_items, :multi_line_string, :multi_line_string, :geographic => true, :has_z => true, :has_m => false
    add_column :geographic_items, :multi_polygon, :multi_polygon, :geographic => true, :has_z => true, :has_m => false
    add_column :geographic_items, :geometry_collection, :geometry_collection, :geographic => true, :has_z => true, :has_m => false
  end
end
