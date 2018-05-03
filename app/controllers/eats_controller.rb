class EatsController < ApplicationController
	def new_event_params
		params.require(:new_event).permit(:title, :start_date, :start_time, :end_date, :end_time, :public, :description, :tags)
	end
	
	def index
		if !(session[:account])
			redirect_to root_path
		end
		@first_name = session[:account]["first_name"]
		@last_name = session[:account]["last_name"]
		@events = Event.where(:creator => session[:account]["id"])
		@events_today = Event.where('start BETWEEN ? AND ?', DateTime.now.beginning_of_day, DateTime.now.end_of_day).all
		@events_today = addTags(@events_today)
		groups = GroupMember.where(:accounts_id => session[:account]["id"]).select(:group_id)
		@groups = Group.where(:id => groups)
		@search_list = session[:search_list]
	end
	
	def new
		new_event = new_event_params
		tags = new_event[:tags].split(",")
		new_entry = Event.new
		new_entry.creator = session[:account]["id"]
		new_entry.title = new_event[:title]
		new_entry.start = DateTime.parse(new_event[:start_date] + " " + new_event[:start_time])
		new_entry.end = DateTime.parse(new_event[:end_date] + " " + new_event[:end_time])
		new_entry.description = new_event[:description]
		if params[:new_event_is_group_event] == "true"
		  new_entry.is_group_event = true
		  new_entry.group_id = params[:new_event_group_id]
		end
		if(new_event[:public] == "1")
			new_entry.public = true
		elsif(new_event[:public] == "0")
			new_entry.public = false
		end
		new_entry.save
		if(tags.length > 0)
			tags.each{ |id|
				new_tag = Tag.new
				new_tag.events_id = new_entry.id
				new_tag.accounts_id = id
				new_tag.save
			}
		end
		if params[:new_event_is_group_event] == "true"
		  redirect_to show_group_profile_path(params[:new_event_group_id])
		else
		  redirect_to eats_wall_path
		end
	end
	
	def editEvent
		@event = Event.find(params[:id])
		@tags = Tag.where(:events_id => params[:id])
		@tagsList = ""
		@tags.each{ |l|
			@tagsList = @tagsList + l.accounts_id.to_s + ","
		}
		session[:return_to] = request.env['PATH_INFO']
		render :layout => false
	end
	
	def updateEvent
		event = Event.find(params[:id])
		event.title = params[:edit_event][:title]
		event.start = DateTime.parse(params[:edit_event][:start_date] + " " + params[:edit_event][:start_time])
		event.end = DateTime.parse(params[:edit_event][:end_date] + " " + params[:edit_event][:end_time])
		event.description = params[:edit_event][:description]
		if(params[:edit_event][:public] == "1")
			event.public = true
		elsif(params[:edit_event][:public] == "0")
			event.public = false
		end
		event.save
		
		tags_array = params[:edit_event][:tags].split(",")
		tags_in_db = Tag.where(:events_id => params[:id])
		tags_in_db.each{ |tag|
			if(!(tags_array.include?(tag.accounts_id)))
				tag.destroy
			end
		}
		tags_array.each{ |id|
			if(Tag.where(:events_id => params[:id], :accounts_id => id).empty?)
				new_tag = Tag.new
				new_tag.events_id = params[:id]
				new_tag.accounts_id = id
				new_tag.save
			end
		}
		redirect_to eats_wall_path
	end
	
	def showEvent
		@event = Event.find(params[:id])
		@creator_name = Account.where(:id => @event.creator).select(:first_name, :last_name).first
		@event.tags = getTags(params[:id])
		is_in_group = false;
		if @event.is_group_event
			@group = Group.find(@event.group_id)
			@is_in_group = GroupMember.where(:group_id => @group.id, :accounts_id => session[:account]["id"]).empty?
		end
		if(session[:account]["id"] == @event.creator or @event.tags.has_key?(session[:account]["id"]) or @is_in_group)
			@is_accessible = true
		else
			@is_accessible = false
		end
	end
	
	def showProfile
		@account = Account.find(params[:id])
		@created_events = Event.where(:creator => params[:id])
		@created_events = addTags(@created_events)
		@tagged_events = Event.where(:id => Tag.where(:accounts_id => params[:id]).pluck(:events_id))
		@tagged_events = addTags(@tagged_events)
		@group_events = GroupMember.where(:accounts_id => params[:id])
		@group_events = Group.where(:id => @group_events.select(:group_id))
		@group_events = Event.where(:group_id => @group_events.select(:id))
		@group_events = addTags(@group_events)
		@all_events = @created_events+@tagged_events+@group_events
		@all_events = @all_events.sort_by { |x|
			x.start
		}
		groups = GroupMember.where(:accounts_id => session[:account]["id"]).select(:group_id)
		@groups = Group.where(:id => groups)
		if(params[:day])
			@date = DateTime.strptime(params[:day], "%m-%d-%Y")
		end
	end
	
	def showGroupProfile
		@group = Group.find(params[:id])
		@groupAdmins = GroupMember.where(:group_id => params[:id], :is_admin => true)
		@groupMembers = GroupMember.where(:group_id => params[:id], :is_admin => false)
		@groupAdmins = Account.where(:id => @groupAdmins.select(:accounts_id)).select(:first_name, :last_name, :id)
		@groupMembers = Account.where(:id => @groupMembers.select(:accounts_id)).select(:first_name, :last_name, :id)
		
		if(GroupMember.where(:group_id => params[:id], :accounts_id => session[:account]["id"]).empty?)
			@is_member = true;
		else
			@is_member = false;
		end
		buff = GroupMember.where(:group_id => params[:id]).select(:accounts_id);
		@membersList = "";
		buff.each{ |id|
			if(!(id.accounts_id == session[:account]["id"]))
				@membersList = @membersList + id.accounts_id.to_s + ","
			end
		}
		buff = GroupMember.where(:group_id => params[:id], :accounts_id => session[:account]["id"])
		@is_member = !buff.empty?
		@is_admin = false
		if @is_member
		  @is_admin = buff.first.is_admin
		end
		if @is_admin
			@joinRequests = GroupJoinRequest.where(:groups_id => params[:id])
			@joinRequests = Account.where(:id => @joinRequests.select(:accounts_id)).select(:id, :first_name, :last_name)
		end
		@group_events = Event.where(:group_id => params[:id])
	end
	
	def membersUpdate
		members = params[:new_group][:members]
		members = members.split(",")
		members_in_db = GroupMember.where(:group_id => params[:id])
		members_in_db.each{ |member|
			if(!(members.include?(member.accounts_id.to_s)) and member.accounts_id != session[:account]["id"])
				member.destroy
			end
		}
		members.each{ |id|
			if GroupMember.where(:group_id => params[:id], :accounts_id => id).empty?
				new_group_member = GroupMember.new
				new_group_member.group_id = params[:id]
				new_group_member.accounts_id = id
				new_group_member.is_admin = false
				new_group_member.save
			end
		}
		redirect_to show_group_profile_path(params[:id])
	end
	
	def changeToAdmin
		gm = GroupMember.where(:group_id => params[:group_id], :accounts_id => params[:acc_id]).first
		gm.is_admin = true
		gm.save
		redirect_to show_group_profile_path(params[:group_id])
	end
	
	def removeFromAdmin
		gm = GroupMember.where(:group_id => params[:group_id], :accounts_id => params[:acc_id]).first
		gm.is_admin = false
		gm.save
		redirect_to show_group_profile_path(params[:group_id])
	end
	
	def joinGroup
		gm = GroupJoinRequest.new
		gm.accounts_id = params[:acc_id]
		gm.groups_id = params[:group_id]
		gm.save
		redirect_to show_group_profile_path(params[:group_id])
	end
	
	def joinGroupResponse
		GroupJoinRequest.delete_all(:groups_id => params[:group_id], :accounts_id => params[:acc_id])
		if(params[:accept] == "true")
			gm = GroupMember.new
			gm.accounts_id = params[:acc_id]
			gm.group_id = params[:group_id]
			gm.is_admin = false;
			gm.save
		end
		redirect_to show_group_profile_path(params[:group_id])
	end
	
	def createGroup
	    if Group.where(:name => params["new_group"]["name"]).empty?
			new_group = Group.new
			new_group.name = params["new_group"]["name"]
			new_group.creator_id = session[:account]["id"]
			creator = Account.find(session[:account]["id"])
			new_group.creator_name = creator.first_name + " " + creator.last_name
			new_group.save
			new_group_member = GroupMember.new
			new_group_member.group_id = new_group.id
			new_group_member.accounts_id = session[:account]["id"]
			new_group_member.is_admin = true
			new_group_member.save
			if params["new_group"]["members"]
			  ids = params["new_group"]["members"].split(",")
			  ids.each{ |id|
				new_group_member = GroupMember.new
				new_group_member.group_id = new_group.id
				new_group_member.accounts_id = id
				new_group_member.is_admin = false
				new_group_member.save
			  }
			end
		end
		redirect_to eats_wall_path
	end
	
	def deleteGroup
		group = Group.find(params[:id])
		members = GroupMember.where(:group_id => params[:id])
		group.destroy
		members.each{ |member|
			member.destroy
		}
		#delete all events of group
		@events = Event.where(:group_id => params[:id])
		@events.each{ |event|
			event.destroy
		}
		redirect_to eats_wall_path
	end
	
	def loadCalendar
		@date = DateTime.strptime(params[:day], "%m-%d-%Y")
		@events = Hash.new
		if(params[:ids])
			@ids = params[:ids].split(",").uniq
			@id_list = ""
			@ids.each{ |id|
				@id_list = @id_list + id + ","
				if(id.starts_with?("group_"))
					g_id = id.split("_")[1]
					group = Group.find(g_id)
					group_events = Event.where(:is_group_event => true, :group_id => g_id)
					group_events = filterDateRange(group_events, params[:view_type], @date)
					if (GroupMember.where(:accounts_id => session[:account]["id"], :group_id => g_id).empty?)
						group_events = group_events.where(:public => true)
					end
					group_events = addTags(group_events)
					@events[group.name] = group_events
				else
					user = Account.find(id)
					user_created_events = Event.where(:creator => id, :is_group_event => false)
					if(!(id.to_s == session[:account]["id"].to_s))
						user_created_events = user_created_events.where(:public => true)
					end
					user_created_events = filterDateRange(user_created_events, params[:view_type], @date)
					user_created_events = addTags(user_created_events)
					tagged_events = Event.where(:id => Tag.where(:accounts_id => id).pluck(:events_id))
					if(!(id.to_s == session[:account]["id"].to_s))
						tagged_events = tagged_events.where(:public => true)
					end
					tagged_events = filterDateRange(tagged_events, params[:view_type], @date)
					tagged_events = addTags(tagged_events)
					group_events = GroupMember.where(:accounts_id => id)
					group_events = Event.where(:group_id => group_events.select(:group_id))
					group_events = filterDateRange(group_events, params[:view_type], @date)
					group_events = addTags(group_events)
					user_event = user_created_events + tagged_events + group_events
					@events[user.first_name + " " + user.last_name] = user_event
				end
			}
			
		end
		render :layout => false
	end	
	
	def suggestInput
		@suggestions = Account.where("first_name like '#{params[:name]}%' AND id != #{session[:account]["id"]}").select(:id, :first_name, :last_name);
		if(params[:with_group] == "1")
			@with_group = true;
			@group_suggestions = Group.where("name like '#{params[:name]}%'").select(:id, :name);
		end
		render :layout => false
	end
	
	def addTag
		@tags = [];
		@yield = "";
		if(params[:tags])
			@ids = params[:tags].split(",").uniq
			@ids.each{ |x|
				@yield = @yield + x + ","
			}
			@tags = Account.where(:id => @ids).select(:id, :first_name, :last_name)
		end
		render :layout => false
	end
	
	def editAddTag
		@tags = [];
		@yield = "";
		if(params[:tags])
			@ids = params[:tags].split(",").uniq
			@ids.each{ |x|
				@yield = @yield + x + ","
			}
			@tags = Account.where(:id => @ids).select(:id, :first_name, :last_name)
		end
		render :layout => false
	end
	
	def addSearchList
		@tags = [];
		@group_tags = [];
		@yield = "";
		@group_ids = [];
		if(params[:searches])
			@ids = params[:searches].split(",").uniq
			ids = [];
			@ids.each{ |x|
				if(x.starts_with?("group_"))
					@group_ids << x.split("_")[1]
				else
					ids << x;
				end
				@yield = @yield + x + ","
			}
			@tags = Account.where(:id => @ids).select(:id, :first_name, :last_name)
			@group_tags = Group.where(:id => @group_ids).select(:id, :name)
		end
		session[:search_list] = @yield
		render :layout => false
	end
	
	def addMemberList
		@tags = [];
		@yield = "";
		if(params[:ids])
			@ids = params[:ids].split(",").uniq
			@ids.each{ |x|
				@yield = @yield + x + ","
			}
			@tags = Account.where(:id => @ids).select(:id, :first_name, :last_name)
		end
		render :layout => false
	end
	
	def removeTag
		@ids = params[:tags].split(",").uniq
		@ids.delete "#{params[:id]}"
		@yield = "";
		if(@ids)
			@ids.each{ |x|
				@yield = @yield + x + ","
			}
		end
		params[:tags] = @yield
		redirect_to('/addTag/'+@yield);
	end
	
	def editRemoveTag
		@ids = params[:tags].split(",").uniq
		@ids.delete "#{params[:id]}"
		@yield = "";
		if(@ids)
			@ids.each{ |x|
				@yield = @yield + x + ","
			}
		end
		params[:tags] = @yield
		redirect_to('/editAddTag/'+@yield);
	end
	
	def removeSearch
		@ids = params[:searches].split(",").uniq
		@ids.delete "#{params[:id]}"
		@yield = "";
		if(@ids)
			@ids.each{ |x|
				@yield = @yield + x + ","
			}
		end
		params[:searches] = @yield
		redirect_to('/addSearchList/'+@yield);
	end
	
	def removeAddMember
		@ids = params[:ids].split(",").uniq
		@ids.delete "#{params[:id]}"
		@yield = "";
		if(@ids)
			@ids.each{ |x|
				@yield = @yield + x + ","
			}
		end
		params[:ids] = @yield
		redirect_to('/addMemberList/'+@yield);
	end
	
	def searchSchedules
		@events = Hash.new
		if(params[:ids])
			@ids = params[:ids].split(",").uniq
			@ids.each{ |id|
				if id.starts_with?("group_")
					g_id = id.split("_")[1]
					group = Group.find(g_id)
					group_events = Event.where(:is_group_event => true, :group_id => g_id)
					if (GroupMember.where(:accounts_id => session[:account]["id"], :group_id => g_id).empty?)
						group_events = group_events.where(:public => true)
					end
					group_events = addTags(group_events)
					@events[group.name] = group_events
				else
					user = Account.find(id)
					user_created_events = Event.where(:creator => id, :public => true)
					user_created_events = addTags(user_created_events)
					tagged_events = Event.where(:id => Tag.where(:accounts_id => id).pluck(:events_id), :public => true)
					tagged_events = addTags(tagged_events)
					group_events = GroupMember.where(:accounts_id => id)
					group_events = Event.where(:group_id => group_events.select(:group_id))
					group_events = addTags(group_events)
					user_event = user_created_events + tagged_events + group_events
					@events[user.first_name + " " + user.last_name] = user_event
				end
			}
		end
		render :layout => false
	end
	
	private
	
	def addTags(events)
		events.each{ |event|
			event.tags = getTags(event.id)
		}
		events
	end
	
	def getTags(event_id)
		event = Event.find(event_id)
		tags = Tag.where(:events_id => event_id)
		ret = Hash.new
		tags.each{ |tag|
			acc = Account.find(tag.accounts_id)
			ret[tag.accounts_id] = acc.first_name + " " + acc.last_name
		}
		ret
	end
	
	def filterDateRange(events ,view_type, date)
		if(view_type == "month")
			events = events.where("(start BETWEEN ? AND ?) OR (end BETWEEN ? AND ?) OR ((start <= ?) AND (end >= ?))", date.beginning_of_month, date.end_of_month, date.beginning_of_month, date.end_of_month, date.beginning_of_month, date.end_of_month)
			#events = events.where(:start => date.beginning_of_month..date.end_of_month, :end => date.beginning_of_month..date.end_of_month)
		elsif(view_type == "week")
			events = events.where("(start BETWEEN ? AND ?) OR (end BETWEEN ? AND ?) OR ((start <= ?) AND (end >= ?))", date.beginning_of_week-1, date.end_of_week-1, date.beginning_of_week-1, date.end_of_week-1, date.beginning_of_week-1, date.end_of_week-1)
			#events = events.where(:start => date.beginning_of_week-1..date.end_of_week-1, :end => date.beginning_of_week-1..date.end_of_week-1)
		elsif(view_type == "day")
			events = events.where("(start BETWEEN ? AND ?) OR (end BETWEEN ? AND ?) OR ((start <= ?) AND (end >= ?))", date.beginning_of_day, date.end_of_day, date.beginning_of_day, date.end_of_day, date.beginning_of_day, date.end_of_day)
			#events = events.where(:start => date.beginning_of_day..date.end_of_day, :end => date.beginning_of_day..date.end_of_day)
		end
	end
end
