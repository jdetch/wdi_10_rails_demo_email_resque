class UserMailer < ActionMailer::Base
  # By default the email is from GA
  default from: "ga@example.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.signup_confirmation.subject
  #
  def signup_confirmation(user)
    # create an instance variable so that the view has access
    # to the user.
    @user = user

    # send email to the user
    mail to: user.email, subject: "Sign Up Confirmation"
  end
end
