class Movie < ApplicationRecord
  IMDB_URL = "https://www.imdb.com"
  ROTTEN_URL = "https://www.rottentomatoes.com"
  METACRITIC_URL = "https://www.metacritic.com"

  ORDER_SQL = "title_normalized ASC, release_date DESC NULLS LAST, wiki_id ASC"

  include PgSearch::Model

  pg_search_scope :search_by_tsv_title,
    against: :title,
    using: {
      tsearch: {
        prefix: true,
        tsvector_column: :tsv_title
      }
    },
    ranked_by: ":trigram",
    order_within_rank: ORDER_SQL

  pg_search_scope :search_by_tsv_title_original,
    against: :title_original,
    using: {
      tsearch: {
        prefix: true,
        tsvector_column: :tsv_title_original
      }
    },
    ranked_by: ":trigram",
    order_within_rank: ORDER_SQL

  def imdb_url
    return unless imdb_id

    "#{IMDB_URL}/title/#{imdb_id}"
  end

  def rotten_url
    return unless rotten_id

    "#{ROTTEN_URL}/#{rotten_id}"
  end

  def metacritic_url
    return unless metacritic_id

    "#{METACRITIC_URL}/#{metacritic_id}"
  end

  def year
    release_date&.year
  end

  def self.search_by_title(title, limit:)
    title_normalized = normalize(title)

    sql = <<~SQL.squish
      (
        (#{search_by_tsv_title(title_normalized).with_pg_search_rank.to_sql})
          UNION
        (#{search_by_tsv_title_original(title.downcase).with_pg_search_rank.to_sql})
      ) AS movies
    SQL

    # Fetch double the records since on the db level the records are not distinct due to `pg_search_rank`.
    # We then make the records unique in memory and restrict by the actual limit
    from(sql).limit(limit * 2).order("pg_search_rank DESC, #{ORDER_SQL}").uniq[0, limit]
  end

  def self.search(query, limit:)
    query_downcased = query.downcase
    if query_downcased =~ /^tt\d+$/
      where(imdb_id: query_downcased)
    elsif query_downcased =~ /^q\d+$/
      where(wiki_id: query_downcased.upcase)
    else
      search_by_title(query, limit:)
    end
  end

  def self.normalize(term)
    return unless term

    I18n.transliterate(term).downcase.gsub(/[[:punct:]]/, "")
  end

  def self.cached_count
    SimpleStore.fetch("movie_count") do
      Movie.count
    end
  end
end
