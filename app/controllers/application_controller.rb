require 'json'

class ApplicationController < ActionController::API
	before_filter :set_cors_headers

	def car
		render json: CarTrip.new(params[:origin]).car
	end

	def transit
		render json: Trip.new(params[:origin], params[:destination])
	end

	private
		def set_cors_headers
			headers['Access-Control-Allow-Origin'] = '*'
			headers['Access-Control-Allow-Methods'] = 'GET'
		end
end
