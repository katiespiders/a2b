require 'httparty'
require 'geocoder'
require 'json'

class ApplicationController < ActionController::API
	def trip_options
		car_trip = CarTrip.new(origin_coords, destination_coords)
		walk_trip = WalkTrip.new(origin_coords, destination_coords)
		transit_trip = TransitTrip.new(origin_coords, destination_coords)
		routes = { car: car_trip.route, walk: walk_trip.route, transit: transit_trip.routes }
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
