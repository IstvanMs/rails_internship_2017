class User < ApplicationRecord
	attr_accessor :password
	USERNAME_REGEX = /\w\z/i
	validates :username, :presence => true, :uniqueness => true, :length => { :in => 3..20 }
	validates :username, :presence => true, :format => USERNAME_REGEX
	validates :password, :confirmation => true
	validates :password, :presence => true,:length => { :in => 6..20 }
	validates_length_of :password, :in => 6..20, :on => create 

	before_save :encrypt_password
	after_save :clear_password

	def encrypt_password
		if password.present?
			self.salt = BCrypt::Engine.generate_salt
			self.encrypted_password = BCrypt::Engine.hash_secret(password, salt)
		end
	end

	def clear_password
		self.password = nil
	end

	def self.authenticate(username="",login_password="")
		user = User.find_by_username(username)

		if user && user.match_password(login_password)
			return user
		else
			return false
		end
	end
	
	def match_password(login_password="")
		encrypted_password == BCrypt::Engine.hash_secret(login_password, salt)
	end
end
