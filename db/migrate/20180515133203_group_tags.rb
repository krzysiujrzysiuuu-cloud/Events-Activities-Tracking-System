class GroupTags < ActiveRecord::Migration
  def change
    create_table :group_tags do |t|
      t.integer :events_id
      t.integer :group_id

      t.timestamps null: false
    end
  end
end
