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
			Account.create(first_name: fn, last_name: ln, email: em, username: un, password: ps)
			flash[:notice] = "Sign up successful!"
		elsif(new_account[:password] != new_account[:confirm_password])
			flash[:warning] = "Password is not equal"
		end
		redirect_to '/'
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
		if(params[:id].to_s == session[:account]["id"].to_s and 
		   Account.find(params[:id]).password == params[:change_password][:current_password] and
		   params[:change_password][:new_password] == params[:change_password][:confirm_new_password])
			account = Account.find(params[:id])
			account.password = params[:change_password][:new_password]
			account.save!
		end
		redirect_to showProfile_path params[:id]
	end
	
	def changeAvatar
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
		redirect_to showProfile_path params[:id]
	end
	
	def removeAvatar
		if(params[:id].to_s == session[:account]["id"].to_s)
			account = Account.find(params[:id])
			account.remove_avatar!
			account.save
		end
		redirect_to showProfile_path params[:id]
	end
end
