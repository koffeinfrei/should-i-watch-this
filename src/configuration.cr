class Configuration
  getter config_file : String = Path.home.join(".config", ".should-i-watch-this").to_s

  def key
    File.read(config_file)
  end

  def configure!(force = false)
    return if File.exists?(@config_file) && !force

    puts <<-MESSAGE
       Hi! #{Emoji.emojize(":wave:")}

       I'll bother you only once with this.

       You need to get an API key from OMDB first.
       I'll open the website where you can get one for free.
       After following the instructions from OMDB you can continue here and paste the key.


    MESSAGE
    print "   ⟶  Please hit <ENTER> to open the website: "
    gets
    `$(which xdg-open || which open) http://www.omdbapi.com/apikey.aspx`

    puts <<-MESSAGE

       Alright. If you did everything right you should now have an API key.
    MESSAGE
    print "   ⟶  Please paste your API key: "
    key = gets

    Dir.mkdir_p(File.dirname(@config_file))
    File.write(@config_file, key)

    puts <<-MESSAGE

       That's it!
       I'll now start the actual application...



    MESSAGE
  end
end
