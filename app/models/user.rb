class User < ApplicationRecord

	has_many :projectUsers , dependent: :destroy
	has_many :projects, through: :projectUsers , dependent: :destroy
	has_many :workDays, dependent: :destroy
	has_many :comments, dependent: :destroy
	has_many :userFields, dependent: :destroy
	belongs_to :company

	attr_accessor :password
	USERNAME_REGEX = /\w\z/i
	EMAIL_REGEX = /\A[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\z/i
	validates :username, :presence => true, :uniqueness => true, :length => { :in => 3..20 }
	validates :username, :presence => true, :format => USERNAME_REGEX
	validates :password, :confirmation => true
	validates :password, :presence => true,:length => { :in => 6..20 }
	validates_length_of :password, :in => 6..20, :on => create 
	validates :email, :presence => true, :format => EMAIL_REGEX, :length => { :in => 6..50 }

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

	def get_work_day
		WorkDay.get_work_day_manager(id)
	end

end
