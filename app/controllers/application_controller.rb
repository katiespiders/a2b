require 'httparty'

class ApplicationController < ActionController::API
	def index
		render json: {"hi": "here i am"}
	end

	private
	
		def origin
			{ latitude: 47.687165,
				longitude: -122.352925 }
		end

		def destination 
			{ latitude: 47.606968,
				longitude: -122.305192 }
		end
		
		def get_cars
			url = "https://www.car2go.com/api/v2.1/vehicles?loc=seattle&oauth_consumer_key=#{ENV['CAR2GO_KEY']}&format=json"
			HTTParty.get(url)
		end

		def get_buses
			url = ""
			HTTParty.get(url)
		end

		def get_directions
			# THIS URL WORKS (IF YOU WANT TO WALK)
			# http://localhost:8080/otp/routers/default/plan?fromPlace=47.687165,-122.352925&toPlace=47.606968,-122.305192&mode=WALK
			#
			# THIS URL WORKS FOR TRANSIT HOLY SHIT!
			# DO *NOT* USE mode=TRANSIT OR IT WILL GO INSANE
			# http://localhost:8080/otp/routers/default/plan?fromPlace=47.60886,-122.334395&toPlace=47.687107,-122.352936
		end
end
