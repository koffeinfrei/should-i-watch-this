require "cli"
require "emoji"

require "./lookup"
require "./configuration"

HELP_FOOTER = "Made with #{Emoji.emojize(":coffee:")}  by Koffeinfrei"

class ShouldIWatchThis < Cli::Supercommand
  command "lookup"
  command "configure"
  version {{ `shards version #{__DIR__}`.chomp.stringify }}

  class Help
    header "Simple CLI to ask the internet if it's worth watching this movie."
    footer HELP_FOOTER
  end

  class Options
    version
  end

  class Lookup < Cli::Command
    class Options
      arg "title_or_imdb_id",
        required: true,
        desc: "The title or the IMDb id of the movie"
      string ["-y", "--year"],
        required: false,
        desc: "The relase year of the movie"
      bool ["-l", "--show-links"],
        default: false,
        desc: "Output links to movies on the different platforms"
      version
      help
    end

    class Help
      header "Lookup a movie and tell if it's worth watching."
      footer HELP_FOOTER
    end

    def run
      Configuration.new.configure!

      # if a title is not provided in quotes we append the remaining arguments
      # to the title argument
      title_or_imdb_id = ([args.title_or_imdb_id] + args.nameless_args).join(" ")

      ::Lookup.new(title_or_imdb_id, show_links: args.show_links?, year: args.year?).run
    end
  end

  class Configure < Cli::Command
    class Options
      bool "--force",
        default: false,
        desc: "Reconfigure, even if the config already exists"
      version
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
