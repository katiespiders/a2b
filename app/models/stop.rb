require 'httparty'

class Stop

  def initialize(stop, trip_id)
    @name = stop['name']
    @stop_id = '1_' + stop['stopId']['id']
		@trip_id = trip_id
		@scheduled = stop['arrival']
    @actual = arrival
  end

  def to_s
    "#{@name} at #{Time.at(@scheduled/1000).strftime("%H:%M")}"
  end

	def all_arrivals
		HTTParty.get("http://api.pugetsound.onebusaway.org/api/where/arrivals-and-departures-for-stop/#{@stop_id}.json?key=#{ENV['OBA_KEY']}")['data']['entry']['arrivalsAndDepartures']
	end

	def arrival
		a = all_arrivals.find { |arrival| arrival['tripId'] == @trip_id }
		if a && a['predicted']
			@real_time = true
			a['predictedArrivalTime']
		else
			@real_time = false
			@scheduled
		end
	end
end
