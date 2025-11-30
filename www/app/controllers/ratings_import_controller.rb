class RatingsImportController < ApplicationController
  def new
  end

  def create
    file = params.require(:file)
    result = ImdbRatingsImport.new(current_user, file.to_io).create

    flash[:success] = <<~MESSAGE.strip
      Your IMDb ratings were imported:
      <ul class="text-start">
        <li>New items: #{result.new}</li>
        <li>Existing items: #{result.existing}</li>
        <li>Failed items: #{result.failed}</li>
      </ul>
    MESSAGE

    redirect_to [:ratings]
  end
end
