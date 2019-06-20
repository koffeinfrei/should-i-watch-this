require "cli"

require "./fetcher"

class ShouldIWatchThis < Cli::Command
  class Help
    header "Check the different internets if it's worth watching this movie."
    footer "Made with #{Emoji.emojize(":coffee:")} by Koffeinfrei"
  end

  class Options
    arg "title",
      required: true,
      desc: "The title of the movie"
    help
  end

  def run
    Fetcher.new(args.title).run
  end
end

ShouldIWatchThis.run(ARGV)
