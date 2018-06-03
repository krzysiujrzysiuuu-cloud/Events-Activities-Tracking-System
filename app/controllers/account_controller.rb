class AccountController < ApplicationController
	def signup_params
		params.require(:new_account).permit(:first_name, :last_name, :email, :username, :password, :confirm_password)
	end
	
	def login_params
		params.require(:log_in).permit(:username, :password)
	end
	
	def index
		if (session[:account])
			redirect_to eats_wall_path
		end
	end
	
	def login
		login_account = login_params
		currently_logged_in = Account.where(:username => login_account[:username], :password => login_account[:password])
		if(currently_logged_in.empty?)
			flash[:warning] = "Account does not exist!"
			redirect_to root_path
		elsif(currently_logged_in.length == 1)
			flash[:notice] = "You have logged in"
			currently_logged_in.each{ |acc|
				session_account = {:id => acc[:id], :username => acc[:username], :first_name => acc[:first_name], :last_name => acc[:last_name]}
				session[:account] = session_account
			}
			redirect_to eats_wall_path
		end
	end
	
	def logout
		session.clear
		redirect_to root_path
	end
	
	def signup
		# check if fields are valid
		# check if account exists e.g. username, password, email
		new_account = signup_params
		account = nil
		if !Account.where(:username => new_account[:username]).empty?
			flash[:warning] = "Username already exists!"
		elsif !Account.where(:email => new_account[:email]).empty?
			flash[:warning] = "Email is already in use!"
		elsif !Account.where(:first_name => new_account[:first_name], :last_name => new_account[:last_name]).empty?
			flash[:warning] = "Name is already in use!"
		elsif(new_account[:password] == new_account[:confirm_password])
			fn = new_account[:first_name]
			ln = new_account[:last_name]
			em = new_account[:email]
			un = new_account[:username]
			ps = new_account[:password]
			account = Account.create(first_name: fn, last_name: ln, email: em, username: un, password: ps, email_confirmed: false, email_confirm_token: ("Confirm#{DateTime.now}#{em}").hash)
			flash[:notice] = "Sign up successful!"
		elsif(new_account[:password] != new_account[:confirm_password])
			flash[:warning] = "Password is not equal"
		end
		
		if account
			redirect_to email_confirmation_send_path(account.id)
		else
			redirect_to '/'
		end
	end
	
	def settings
		if params[:id].to_s == session[:account]["id"].to_s
			@account = Account.find(params[:id]);
			groups = GroupMember.where(:accounts_id => params[:id]).select(:group_id)
			@groups = Group.where(:id => groups)
			render :layout => 'show_profile_layout'
		else
			redirect_to showProfile_path params[:id]
		end
	end
	
	def changePassword
		account = nil
		if(params[:id].to_s == session[:account]["id"].to_s and 
		   Account.find(params[:id]).password == params[:change_password][:current_password] and
		   params[:change_password][:new_password] == params[:change_password][:confirm_new_password])
			account = Account.find(params[:id])
			account.password = params[:change_password][:new_password]
			account.save!
		end
		
		if account
			flash[:notice] = "Password successfully changed!"
		else
			flash[:warning] = "Password unsuccessfully changed!"
		end
		redirect_to showProfile_path params[:id]
	end
	
	def changeEmail
		account = nil
		email_in_use = !(Account.where(:email => params[:change_email][:email]).empty?)
		if(params[:id].to_s == session[:account]["id"].to_s and 
		   Account.find(params[:id]).password == params[:change_email][:current_password] and
		   !email_in_use)
			account = Account.find(params[:id])
			account.email = params[:change_email][:email]
			account.email_confirmed = false
			account.email_confirm_token = ("Confirm#{DateTime.now}#{params[:change_email][:email]}").hash
			account.save!
		end
		
		if account
			redirect_to email_confirmation_send_path(account.id)
		else
			if email_in_use
				flash[:warning] = "Email is already in use!"
			else
				flash[:warning] = "Email unsuccessfully changed!"
			end
			redirect_to showProfile_path params[:id]
		end
	end
	
	def changeAvatar
		account = nil
		if(params[:id].to_s == session[:account]["id"].to_s)
			begin
				account = Account.find(params[:id])
				account.avatar = params[:account][:avatar]
				account.save!
			rescue ActiveRecord::RecordInvalid => invalid
			end
		end
		#to remove avatar
		#@user.remove_avatar!
        #@user.save
		if account
			flash[:notice] = "Avatar successfully changed!"
		else
			flash[:warning] = "Avatar unsuccessfully changed!"
		end
		redirect_to showProfile_path params[:id]
	end
	
	def removeAvatar
		account = nil
		if(params[:id].to_s == session[:account]["id"].to_s)
			account = Account.find(params[:id])
			account.remove_avatar!
			account.save!
		end
		
		if account
			flash[:notice] = "Avatar successfully changed!"
		else
			flash[:warning] = "Avatar unsuccessfully changed!"
		end
		redirect_to showProfile_path params[:id]
	end
	
	def emailConfirmationSend
		account = Account.find(params[:id])
		if account
			if account.email_confirmed
				flash[:warning] = "Account email already confirmed!"
			elsif AccountsMailer.emailConfirmation(account).deliver_now
				
			else
				flash[:warning] = "Email is already in use!"
			end
		else
			flash[:warning] = "Account does not exist!"
			redirect_to root_path
		end
	end
	
	def emailConfirmation
		account = Account.find(params[:id])
		if account
			if account.email_confirm_token == params[:token]
				account.email_confirmed = true
				account.save!
				flash[:notice] = "Email successfully confirmed!"
			else
				flash[:warning] = "Cannot confirm email!"
			end
		else
			flash[:warning] = "Account does not exist!"
		end
		redirect_to root_path
	end
	
	def passwordResetRequest
		account = Account.find_by(:email => params[:password_reset][:email], :username => params[:password_reset][:username])
		if account
			if account.email_confirmed
				account.pass_reset_token = ("#{account.email}#{DateTime.now}").hash
				account.pass_reset_expiration = DateTime.now.next_week
				account.save!
				AccountsMailer.password_reset(account).deliver_now
				flash[:notice] = "Password reset mail has been sent!"
			else
				flash[:notice] = "Email has not yet been confirmed! Please check your mail for email confirmation!"
			end
		end
		redirect_to root_path
	end
	
	def editResetPassword
		@account = Account.find_by(:pass_reset_token => params[:token], :email => params[:email])
		if @account
		else
			flash[:warning] = "Invalid credentials for password reset!"
			redirect_to root_path
		end
	end
	
	def resetPassword
		account = Account.find(params[:id])
		if account.pass_reset_token == params[:token] and
			params[:change_password][:new_password] == params[:change_password][:confirm_new_password]
			
			account.password = params[:change_password][:new_password]
			account.pass_reset_token = nil
			account.pass_reset_expiration = nil
			account.save!
			flash[:notice] = "Password was successfully reset!"
		else
			flash[:warning] = "Password was unsuccessfully reset!"
		end
		redirect_to root_path
	end
	
	#static pages
	
	def forgotPassword
	end
	
	def passwordResetTokenExpired
	end
end
