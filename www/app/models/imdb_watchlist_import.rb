require "csv"

class ImdbWatchlistImport
  Result = Data.define(:records, :new, :existing, :failed)

  def initialize(user, io)
    @user = user
    @io = io
  end

  def build
    csv = CSV.new(@io, headers: true)

    ids = csv.map { _1["Const"] }
    movie_ids = Movie.where(imdb_id: ids).pluck(:id)

    existing_records = WatchlistItem.where(user: @user, movie_id: movie_ids)

    leftover_ids = movie_ids - existing_records.map(&:movie_id)
    new_records = leftover_ids.map { WatchlistItem.new(user: @user, movie_id: _1) }

    imported_records = existing_records + new_records

    Result.new(
      imported_records,
      new_records.size,
      existing_records.size,
      (ids.size - imported_records.size)
    )
  end
end
