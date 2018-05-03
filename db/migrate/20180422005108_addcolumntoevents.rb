class Addcolumntoevents < ActiveRecord::Migration
  def change
    add_column :events, :is_group_event, :boolean, :default => false
	add_index :events, :creator
  end
end
