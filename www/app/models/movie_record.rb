class MovieRecord < ApplicationRecord
  def self.search_by_title(title)
    order_query = <<~ORDER.strip
      CASE
        WHEN title ILIKE ? THEN 1
        WHEN title ILIKE ? THEN 2
        WHEN title ILIKE ? THEN 3
      END
    ORDER

    where.not(imdb_id: nil)
      .where("title ILIKE ?", "%#{title}%")
      .order(sanitize_sql_for_order([Arel.sql(order_query), title, "#{title}%", "%#{title}"]))
  end

  def self.search(query)
    if query =~ /^tt\d+$/
      where(imdb_id: query)
    else
      search_by_title(query)
    end
  end
end
