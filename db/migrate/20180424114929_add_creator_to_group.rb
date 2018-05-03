class AddCreatorToGroup < ActiveRecord::Migration
  def change
	add_column :groups, :creator_id, :integer
	add_column :groups, :creator_name, :string
  end
end
