class MailWorker
  # All Workers/subscribers MUST have a @queue instance variable
  @queue = :mailer_queue

  def self.perform(user_id)
    @user = User.find(user_id) # Find the newly registered user by id
    UserMailer.signup_confirmation(@user).deliver # Send sign up email
  end
end

