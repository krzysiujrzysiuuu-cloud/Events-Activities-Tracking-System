class AccountsMailer < ApplicationMailer
	default from: "admin@somedomain.com"
	def emailConfirmation(user)
		@user = user
		mail to: user.email, subject: "Email Confirmation"
	end
	
	def password_reset(user)
		@user = user
		mail to: user.email, subject: "Password reset"
	end
end
