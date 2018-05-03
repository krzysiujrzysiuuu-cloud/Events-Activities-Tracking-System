class CreateGroupJoinRequestTable < ActiveRecord::Migration
  def change
    create_table :group_join_requests, {:id => false, :force => true} do |t|
		t.integer :groups_id
		t.integer :accounts_id
		
		t.timestamps null: false
    end
  end
end
