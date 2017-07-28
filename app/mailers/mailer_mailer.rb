class MailerMailer < ApplicationMailer
	default from: "no-reply@example.com"

	def new_user(user)
		puts 'asd'
		@user = user
		mail(to: @user.email, subject: 'Welcome')
	end

	def reset_password(user, password)
		@user = user
		@password = password
		mail(to: @user.email, subject: 'New password')
	end

	def change_email(email, user, old)
		@user = user
		@old = old
		mail(to: email , subject: 'Email changed')
	end

	def assigned_to_project(user, project)
		@project = project
		@user = user
		mail(to: @user.email, subject: 'Assigned Project')
	end

	def assigned_to_task(user, task)
		@task = task
		@user = user
		mail(to: @user.email, subject: 'Assigned Task')
	end

end
