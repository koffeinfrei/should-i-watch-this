require "sparql/client"

class Wikidata
  INSTANCE_OF = "P31"
  HUMANS = "Q5"
  FILM = "Q11424"
  SERIES = "Q5398426"

  def initialize(output_dir)
    @output_dir = Pathname(output_dir)
  end

  def movies_classes
    file = @output_dir.join("wikidata-movies-classes")

    if file.exist?
      JSON.parse(file.read)
    else
      fetch_subclasses(FILM).tap { file.write(JSON.dump(_1)) }
    end
  end

  def series_classes
    file = @output_dir.join("wikidata-series-classes")

    if file.exist?
      JSON.parse(file.read)
    else
      fetch_subclasses(SERIES).tap { file.write(JSON.dump(_1)) }
    end
  end

  def all_classes
    [HUMANS] + movies_classes + series_classes
  end

  private

  def fetch_subclasses(wiki_class)
    sparql = <<~SPARQL.strip
      SELECT DISTINCT ?film WHERE {
        {
          ?film wdt:P279* wd:#{wiki_class} .
        }
      }
    SPARQL

    client = SPARQL::Client.new(
      "https://query.wikidata.org/sparql",
      method: :get,
      headers: { "User-Agent" => "ShouldIWatchThisBot/0.0 (https://www.should-i-watch-this.com; info@should-i-watch-this.com)" }
    )
    rows = client.query(sparql)

    rows.map { |row| row.each_value.map { _1.to_s.split("/").last } }.flatten.sort
  end
end
