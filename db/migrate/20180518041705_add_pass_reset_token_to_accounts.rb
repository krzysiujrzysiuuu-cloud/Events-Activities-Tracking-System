class AddPassResetTokenToAccounts < ActiveRecord::Migration
  def change
	add_column :accounts, :pass_reset_token, :string
	add_column :accounts, :pass_reset_expiration, :datetime
	add_column :accounts, :email_confirmed, :boolean
  end
end
