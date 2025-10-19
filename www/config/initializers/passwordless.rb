Passwordless.configure do |config|
  config.default_from_address = ENV.fetch("SMTP_SENDER")

  config.after_session_save = lambda do |session, _request|
    Passwordless::Mailer.sign_in(session, session.token).deliver_later
  end
end
