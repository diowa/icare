# frozen_string_literal: true

module MailerMacros
  def last_email
    ActionMailer::Base.deliveries.last
  end

  def delivered_emails
    ActionMailer::Base.deliveries
  end

  def reset_email
    ActionMailer::Base.deliveries = []
  end

  def devise_token_from_last_mail(token_name)
    last_email.body.to_s[/#{token_name}_token=([^"]+)/, 1]
  end
end

RSpec.configure do |config|
  config.include MailerMacros

  config.before do
    reset_email
  end
end
