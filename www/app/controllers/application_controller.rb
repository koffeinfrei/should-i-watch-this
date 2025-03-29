class ApplicationController < ActionController::Base
  def quote
    @quote ||= Quote.random
  end
  helper_method :quote
end
