module MessageLogger
  def self.log(message)
    puts message unless ENV["ruby_env"] == "test"
  end

  def self.print(message)
    print message unless ENV["ruby_env"] == "test"
  end
end
