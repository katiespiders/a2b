require 'httparty'
require 'geocoder'
require 'json'

class ApplicationController < ActionController::API
	def trip_options
		car_trip = CarTrip.new(origin_coords, destination_coords)
		# walk_trip = WalkTrip.new(origin_coords, destination_coords)
		transit_trip = TransitTrip.new(origin_coords, destination_coords)

		routes =  {
			car: car_trip.route,
			transit: transit_trip.routes
	 	}
		render json: routes.to_json
	end

	private
		def origin_coords
			# Geocoder.coordinates("352 N. 80th St, Seattle")
			# [47.608830, -122.334411]
			[47.687161, -122.352952]
		end

		def destination_coords
			# Geocoder.coordinates("525 21st Ave, Seattle")
			[47.6069542, -122.3052976]
		end
end
