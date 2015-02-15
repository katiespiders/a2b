require 'httparty'

class Stop
  attr_accessor :name, :actual, :scheduled, :delay, :real_time

  def initialize(stop, trip_id)
    @name = stop['name']
    @stop_id = '1_' + stop['stopId']['id']
		@trip_id = trip_id
		@scheduled = stop['arrival'] / 1000
    @actual = arrival
    @delay = @actual - @scheduled
    @coords = [stop['lat'], stop['lon']]
  end

	def all_arrivals
    url = "http://api.pugetsound.onebusaway.org/api/where/arrivals-and-departures-for-stop/#{@stop_id}.json?key=#{ENV['OBA_KEY']}"
		HTTParty.get(url)['data']['entry']['arrivalsAndDepartures']
	end

	def arrival
    puts "0 s: getting real time arrival data"
    time = Time.now
		a = all_arrivals.find { |arrival| arrival['tripId'] == @trip_id }
    puts "#{Time.now - time} s: got real time arrival data"
		if a && a['predicted']
			@real_time = true
			a['predictedArrivalTime'] / 1000
		else
			@real_time = false
			@scheduled
		end
	end
end
