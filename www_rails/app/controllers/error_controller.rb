class ErrorController < ApplicationController
  def show
    @title = "Breakdown"
    @message = flash[:error]
    @query = flash[:query]
  end

  def not_found
    @title = "404"
    @message = "Oh snap! This is not a movie. This is a 404."

    render :show, status: :not_found
  end
end
