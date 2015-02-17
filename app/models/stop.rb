require 'httparty'

class Stop
  attr_accessor :time, :time_string

  def initialize(stop, trip_id, user_arrival_time=nil)
    @name = stop['name']
    @coords = [stop['lat'], stop['lon']]
    @time = bus_arrival_time(stop, trip_id)
    @time_string = Time.at(@time).strftime("%-I:%M %P")
    @delta = delta(stop)
  end

  private
    def bus_arrival_time(stop, trip_id)
      puts "0 s: getting real time arrival data"

      scheduled = stop['arrival'] / 1000
      time = Time.now

      if Time.at(scheduled) - Time.now < 45.minutes
        arrivals = all_arrivals(stop)
        arrival = arrivals.find { |arrival| arrival['tripId'] == trip_id}
        puts "#{Time.now - time} s: got real time arrival data"
      end

      if arrival && arrival['predicted']
        @real_time = true
        arrival['predictedArrivalTime'] / 1000
      else
        @real_time = false
        scheduled
      end
    end

    def all_arrivals(stop)
      stop_id = '1_' + stop['stopId']['id']
      url = "http://api.pugetsound.onebusaway.org/api/where/arrivals-and-departures-for-stop/#{stop_id}.json?key=#{ENV['OBA_KEY']}"
      HTTParty.get(url)['data']['entry']['arrivalsAndDepartures']
    end

    def delta(stop)
      delay = @time - stop['arrival'] / 1000
      if delay.abs < 60
        @real_time ? 'on time' : 'supposedly'
      elsif delay < 0
        "#{delay.abs / 60} minutes early"
      else
        "#{delay / 60} minutes late"
      end
    end
end
