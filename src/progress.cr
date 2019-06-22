class Progress
  SPINNER_CHARACTERS = %w(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)

  getter movie : Movie

  def initialize(@movie)
  end

  def start
    show_spinner
  end

  def stop(result_text)
    puts <<-DOC
      \r   Movie '#{movie.title}' #{" " * (progress_text.size - done_text.size)}

      #{result_text}

      DOC
  end

  def progress_text
    "Fetching movie '#{movie.title}'"
  end

  def done_text
    "Movie '#{movie.title}':"
  end

  def show_spinner
    loop do
      0.upto(SPINNER_CHARACTERS.size - 1) do |index|
        STDOUT << "\r"
        STDOUT << "#{SPINNER_CHARACTERS[index]}  #{progress_text}"
        STDOUT.flush
        sleep 0.1
      end
    end
  end
end
