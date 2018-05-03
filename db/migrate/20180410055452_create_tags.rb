class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.integer :events_id
      t.integer :accounts_id

      t.timestamps null: false
    end
  end
end
