# Write your soltuion here!
require "http"
require "json"
require "dotenv/load"

#API Keys
pirate_weather_key = ENV.fetch("PIRATE_WEATHER_KEY")
gmaps_key = ENV.fetch("GMAPS_KEY")

puts "========================================"
puts "    Will you need an umbrella today?    "
puts "========================================"
puts "Where are you?"

user_location = gets.chomp

#Google maps
google_maps_url = "https://maps.googleapis.com/maps/api/geocode/json?address="+ user_location + "&key=" + gmaps_key

raw_response = HTTP.get(google_maps_url)

parsed_response = JSON.parse(raw_response)

result = parsed_response.fetch('results')

geo = result[0].fetch('geometry')

loc = geo.fetch('location')

latitude = loc.fetch('lat')
longitude = loc.fetch('lng')

puts "Checking the weather at #{user_location}...."
puts "Your coordinates are #{latitude}, #{longitude}."

#Pirate weather
pirate_weather_url = "https://api.pirateweather.net/forecast/" + pirate_weather_key + "/#{latitude},#{longitude}"

raw_response_pirate = HTTP.get(pirate_weather_url)

parsed_response_pirate = JSON.parse(raw_response_pirate)

currently_hash = parsed_response_pirate.fetch("currently")

current_temp = currently_hash.fetch("temperature")

next_hour = currently_hash.fetch("summary")

puts "The current temperature is " + current_temp.to_s + "\u00b0F."
puts "Next hour: #{next_hour}"

hourly_hash = parsed_response_pirate.fetch("hourly")

data = hourly_hash.fetch('data')

hours = 0
precipitation_prob = 10
precipitation_array = []

13.times do |hours|
  precipitation = data[hours].fetch("precipProbability") * 100
  precipitation_array.push(precipitation.to_i)
  hours += 1
end

counter = 0
precipitation_array.each do |precip|
  if precip > precipitation_prob
    counter += 1
  end
end

possible_rain = true unless counter == 0

if possible_rain == true
  precipitation_array.each do |precip|
    if precip > precipitation_prob
      hour = precipitation_array.index(precip)
      puts "In #{hour} hours, there is a #{precip}% chance of precipitation."
    end
  end
  puts "You might want to carry an umbrella!"
else
  puts "You probably won't need an umbrella today."
end

#ASCII CHART
require 'ascii_charts'

#Histogram
puts "Hours from now vs Precipitation probability"
puts AsciiCharts::Cartesian.new((0..12).to_a.map{|x| [x, precipitation_array[x]]}, :bar => true).draw
