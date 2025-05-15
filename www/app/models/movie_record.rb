class MovieRecord < ApplicationRecord
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
    order_within_rank: "release_date DESC NULLS LAST"

  pg_search_scope :search_by_tsv_title_original,
    against: :title_original,
    using: {
      tsearch: {
        prefix: true,
        tsvector_column: :tsv_title_original
      }
    },
    ranked_by: ":trigram",
    order_within_rank: "release_date DESC NULLS LAST"

  def self.search_by_title(title, limit:)
    title_normalized = I18n.transliterate(title).downcase

    [
      where.not(imdb_id: nil).search_by_tsv_title_original(title.downcase).limit(limit),
      where.not(imdb_id: nil).search_by_tsv_title(title_normalized).limit(limit)
    ].flatten.uniq.take(limit)
  end

  def self.search(query, limit:)
    query_downcased = query.downcase
    if query_downcased =~ /^tt\d+$/
      where(imdb_id: query_downcased)
    else
      search_by_title(query, limit:)
    end
  end
end
