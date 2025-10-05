class WatchlistImportController < ApplicationController
  def new
  end

  def create
    file = params.require(:file)
    result = ImdbWatchlistImport.new(current_user, file.to_io).build

    result.records.each(&:save!)

    flash[:success] = <<~MESSAGE.strip
      Your IMDb watchlist was imported:
      <ul class="text-start">
        <li>New items: #{result.new}</li>
        <li>Existing items: #{result.existing}</li>
        <li>Failed items: #{result.failed}</li>
      </ul>
    MESSAGE

    redirect_to [:watchlist]
  end
end
