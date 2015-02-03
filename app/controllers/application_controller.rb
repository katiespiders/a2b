require 'httparty'
require 'geocoder'

class ApplicationController < ActionController::API
	def trip_options
		render json: itineraries 
	end

	private
		def itineraries
			origin = origin_coords
			destination = destination_coords
			buses = get_buses
			from = buses['from']['name']
			to = buses['to']['name']
			itineraries = buses['itineraries']
			trip = itineraries[0]
			duration = show_duration(trip['duration'])
			raise
		end
		
		def origin_coords
			origin = Geocoder.coordinates("352 N. 80th St, Seattle")
			puts "!"*80, origin
			origin
		end

		def destination_coords
			destination = Geocoder.coordinates("525 21st Ave, Seattle")
			puts "@"*80, destination
			destination
		end

		def get_cars
			url = "https://www.car2go.com/api/v2.1/vehicles?loc=seattle&oauth_consumer_key=#{ENV['CAR2GO_KEY']}&format=json"
			url = "https://www.car2go.com/api/v2.1/vehicles?loc=seattle&oauth_consumer_key=#{ENV['CAR2GO_KEY']}&format=json"
			HTTParty.get(url)
		end

		def get_buses
			origin = origin_coords
			destination = destination_coords
			url = "http://localhost:8080/otp/routers/default/plan?fromPlace=#{origin[0]},#{origin[1]}&toPlace=#{destination[0]},#{destination[1]}"
			puts "*"*80, url
			HTTParty.get(url)['plan']
		end

		def show_duration(seconds)
			hours = (seconds / 3600).floor
			minutes = ((seconds % 3600) / 60).floor
			hours > 0 ? "#{hours} hours and #{minutes} minutes" : "#{minutes} minutes"
		end
end
