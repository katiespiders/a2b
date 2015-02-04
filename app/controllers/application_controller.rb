require 'httparty'
require 'geocoder'

class ApplicationController < ActionController::API
	def trip_options
		trip = Trip.new('TRANSIT', origin_coords, destination_coords)
		routes = trip.routes
		render json: routes 
	end

	private
		def itineraries
			buses = get_buses
			from = buses['from']['name']
			to = buses['to']['name']
			itineraries = buses['itineraries']
			trip = itineraries[0]
			duration = show_duration(trip['duration'])

			{	origin: origin_coords,
				destination: destination_coords,
				buses: buses,
				from: from,
				to: to,
				itineraries: itineraries,
				trip: trip,
				duration: duration
			}
		end
		
		def origin_coords
			o=Geocoder.coordinates("352 N. 80th St, Seattle")
			puts "!"*80, o
			o
		end

		def destination_coords
			d=Geocoder.coordinates("525 21st Ave, Seattle")
			puts "@"*80, d
			d
		end

		def get_cars
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
