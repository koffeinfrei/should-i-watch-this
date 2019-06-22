require "cli"
require "emoji"

require "./fetcher"
require "./configuration"

HELP_FOOTER = "Made with #{Emoji.emojize(":coffee:")} by Koffeinfrei"

class ShouldIWatchThis < Cli::Supercommand
  command "lookup"
  command "configure"

  class Help
    header "Simple CLI to ask the internet if it's worth watching this movie."
    footer HELP_FOOTER
  end

  class Lookup < Cli::Command
    class Options
      arg "title",
        required: true,
        desc: "The title of the movie"
      bool ["-l", "--show-links"],
        default: false,
        desc: "Output links to movies on the different platforms"
      help
    end

    class Help
      header "Lookup a movie and tell if it's worth watching."
      footer HELP_FOOTER
    end

    def run
      Configuration.new.configure!

      Fetcher.new(args.title, show_links: args.show_links?).run
    end
  end

  class Configure < Cli::Command
    class Options
      bool "--force", default: false
      help
    end

    class Help
      header "Configure the application, i.e. set the OMDB API key."
      footer HELP_FOOTER
    end

    def run
      Configuration.new.configure!(force: args.force?)
    end
  end
end

ShouldIWatchThis.run(ARGV)
