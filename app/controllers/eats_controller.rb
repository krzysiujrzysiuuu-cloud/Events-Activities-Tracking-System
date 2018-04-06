class EatsController < ApplicationController
	def index
		if !(session[:account])
			redirect_to root_path
		end
		@first_name = session[:account]["first_name"]
		@last_name = session[:account]["last_name"]
	end
end
