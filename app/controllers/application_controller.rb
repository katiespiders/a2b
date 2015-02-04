require 'httparty'
require 'geocoder'
require 'json'

class ApplicationController < ActionController::API
	def trip_options
		car_trip = Trip.new('CAR', origin_coords, destination_coords)
		walk_trip = Trip.new('WALK', origin_coords, destination_coords)
		transit_trip = Trip.new('TRANSIT', origin_coords, destination_coords)
		routes = { car: car_trip.routes, walk: walk_trip.routes, transit: transit_trip.routes }
		render json: routes.to_json
	end

	private
		def origin_coords
			# Geocoder.coordinates("352 N. 80th St, Seattle")
			[47.687161, -122.352952]
		end

		def destination_coords
			# Geocoder.coordinates("525 21st Ave, Seattle")
			[47.6069542, -122.3052976]
		end

		def show_duration(seconds)
			hours = (seconds / 3600).floor
			minutes = ((seconds % 3600) / 60).floor
			hours > 0 ? "#{hours} hours and #{minutes} minutes" : "#{minutes} minutes"
		end
end
