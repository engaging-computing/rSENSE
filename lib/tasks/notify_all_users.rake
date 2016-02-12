namespace :notify_all_users do
  task reset_passwords: :environment do
  	 User.all.each do |user|
        UserMailer.pw_reset_email(user).deliver
      end
  end
end
