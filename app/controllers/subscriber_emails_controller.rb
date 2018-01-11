class SubscriberEmailsController < ApplicationController
	def new
		unless current_user.admin
			render_404
		end

		@subscriber_email = SubscriberEmail.new
	end

	def create
		@subscriber_email = SubscriberEmail.new(subscriber_email_params)
		if @subscriber_email.save
			User.subscribed_users.each do |u|
				UserMailer.send_subscriber_email(u, @subscriber_email).deliver
			end
			flash[:success] = 'Successfully sent out the email!'
			redirect_to root_path
		end
	end

	private

	def subscriber_email_params
		params[:subscriber_email].permit(:subject, :message)
	end
end
