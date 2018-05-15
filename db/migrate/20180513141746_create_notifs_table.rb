class CreateNotifsTable < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
		t.integer :accounts_id
		t.string :content
		t.boolean :is_read
		
		t.timestamps
	end
	
	create_table :group_notifications do |t|
		t.integer :group_id
		t.boolean :for_all
		t.integer :accounts_id
		t.string :content
		t.boolean :is_read
		
		t.timestamps
	end
  end
end

