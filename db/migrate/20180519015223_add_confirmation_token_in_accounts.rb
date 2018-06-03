class AddConfirmationTokenInAccounts < ActiveRecord::Migration
  def change
	add_column :accounts, :email_confirm_token, :string
  end
end
