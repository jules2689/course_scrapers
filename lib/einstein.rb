Dir[File.dirname(__FILE__) + '/einstein/*.rb'].each do |file| 
  require_relative file
end

module Einstein

end
