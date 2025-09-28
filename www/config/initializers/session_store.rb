Rails.application.config.session_store :cookie_store,
  key: "_should_i_watch_this_session",
  expire_after: 1.year
