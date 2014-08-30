require "pathname"

require 'dotenv'
Dotenv.load

require_relative './wunderground_client.rb'

wunderground = WundergroundClient.new(api_key: ENV.fetch('WUNDERGROUND_API_KEY'))

marseille_coordinates = "43.381874,5.355597"
dates = if ENV['FROM'] && ENV['TO']
  Range.new(Date.parse(ENV['FROM']), Date.parse(ENV['TO'])).to_a
elsif ENV['DATE']
  Array(Date.parse(ENV['DATE']))
else
  fail ArgumentError, "You need to provide either (FROM and TO) or DATE environment variables"
end

dates.each do |date|
  puts date
  result = wunderground.get_history(where: marseille_coordinates, date: date)

  file = Pathname("data/wunderground/marseille_#{date.strftime('%Y%m%d')}.json")
  file.dirname.mkpath

  file.write(result)
  sleep 6
end