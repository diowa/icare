class EmailSender
  @queue = :emails_queue

  def self.perform(mailer, method, user_id)
    user = User.find(user_id)
    mailer_class = Kernel.const_get(mailer)
    mail = mailer_class.send(method.to_sym, user)
    if defined?(ActionMailer) and mailer_class.superclass == ActionMailer::Base
      mail.deliver
    end
  end
end
