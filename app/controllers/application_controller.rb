require 'json'

class ApplicationController < ActionController::API
	before_filter :set_cors_headers

	def car
		render json: CarTrip.new(params[:origin]).car
	end

	def transit
		render json: TransitTrip.new(params[:origin], params[:destination]).trip
	end

	private
		def set_cors_headers
			headers['Access-Control-Allow-Origin'] = Rails.env.development? ? 'http://localhost:9393' : 'http://seattle-a2b.com'
			headers['Access-Control-Allow-Methods'] = 'GET'
		end
end
