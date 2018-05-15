require 'carrierwave/orm/activerecord'

class Account < ActiveRecord::Base
	mount_uploader :avatar, AvatarUploader
end