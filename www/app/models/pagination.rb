class Pagination
  PER = 10

  Result = Data.define(:previous, :current, :next)

  def self.apply(collection, page, per: PER)
    # fetch one record too many...
    collection = collection.offset((page - 1) * per).limit(per + 1)

    # ...to determine if there's a next page
    next_page =
      if collection.to_a.size > per
        page + 1
      end
    previous_page =
      if page - 1 >= 1
        page - 1
      end

    collection = collection[0, per]

    [collection, Result.new(previous_page, page, next_page)]
  end
end
