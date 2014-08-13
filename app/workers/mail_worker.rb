class MailWorker

  @queue = :mailer_queue

  def self.perform(user_id)
    @user = User.find(user_id)
    # Send sign up email
    UserMailer.signup_confirmation(@user).deliver
  end
end
