class UserMailer < ActionMailer::Base

  default from: APP_CONFIG.mailer.from
=begin
  # Example
  def activation_success_email(user)
    @user = user
    @url  = "#{APP_CONFIG.base_url}/login"
    mail(to: user.email, subject: t('user_mailer.activation_success_email.subject'))
  end
=end
end
