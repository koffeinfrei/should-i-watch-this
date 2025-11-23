module Quote
  def self.random
    all.sample
  end

  def self.all
    from_file("afis-100.json") + from_file("lifehack-25.json")
  end

  def self.from_file(file_name)
    json = Oj.load(
      File.read(File.join(__dir__, "quotes", file_name))
    )
    json.map { RecursiveOstruct.from(_1) }
  end
end
