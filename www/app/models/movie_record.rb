class MovieRecord < ApplicationRecord
  def self.search_by_title(title)
    title_normalized = I18n.transliterate(title).downcase

    order_query = <<~ORDER.strip
      CASE
        WHEN title_normalized LIKE ? THEN 1
        WHEN title_original ILIKE ? THEN 1
        WHEN title_normalized LIKE ? THEN 2
        WHEN title_original ILIKE ? THEN 2
        WHEN title_normalized LIKE ? THEN 3
        WHEN title_original ILIKE ? THEN 3
      END
    ORDER
    order = sanitize_sql_for_order([
      Arel.sql(order_query),
      title_normalized,
      title,
      "#{title_normalized}%",
      "#{title}%",
      "%#{title_normalized}",
      "%#{title}"
    ])

    where.not(imdb_id: nil)
      .where("title_normalized LIKE ?", "%#{title}%")
      .or(where("title_original ILIKE ?", "%#{title}%"))
      .order(order)
  end

  def self.search(query)
    query_downcased = query.downcase
    if query_downcased =~ /^tt\d+$/
      where(imdb_id: query_downcased)
    else
      search_by_title(query)
    end
  end
end
