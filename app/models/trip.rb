require 'httparty'
require 'latitude'

class Trip
  include Mongoid::Document

  field :start_time, type: Time
  field :end_time, type: Time
  field :mode, type: String # CAR, WALK, TRANSIT
	field :cost, type: Integer # transit fare or approx. car2go cost
	field :directions, type: Array # of street_legs and transit_legs
	field :origin, type: Array #[latitude, longitude]
	field :destination, type: Array #[latitude, longitude]

	def initialize(mode, origin, destination)
		@mode = mode
		@origin = origin.join(",")
		@destination = destination.join(",")
	end

	def cars
		HTTParty.get("https://www.car2go.com/api/v2.1/vehicles?loc=seattle&oauth_consumer_key=#{ENV['CAR2GO_KEY']}&format=json")
	end

	def routes
	end
end
