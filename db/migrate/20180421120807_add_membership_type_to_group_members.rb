class AddMembershipTypeToGroupMembers < ActiveRecord::Migration
  def change
    add_column :group_members, :is_admin, :boolean
  end
end
