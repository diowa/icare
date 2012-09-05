class UserMailer < ActionMailer::Base

  default from: APP_CONFIG.mailer.from

  def activation_needed_email(user)
    @user = user
    @url  = "#{APP_CONFIG.base_url}/users/#{user.activation_token}/activate"
    mail(to: user.email, subject: t('user_mailer.activation_needed_email.subject', website: "minstrels.com"))
  end

  def activation_success_email(user)
    @user = user
    @url  = "#{APP_CONFIG.base_url}/login"
    mail(to: user.email, subject: t('user_mailer.activation_success_email.subject'))
  end

  def reset_password_email(user)
    @user = user
    @url  = "#{APP_CONFIG.base_url}/password_resets/#{user.reset_password_token}/edit"
    mail(to: user.email, subject: t('user_mailer.reset_password_email.subject'))
  end
end
