require 'httparty'

class Stop
  attr_accessor :time, :time_string, :trip_id

  def initialize(stop, user_arrival_time: nil, route: nil, trip_id: nil)
    @user_arrival_time = user_arrival_time
    @route = route
    @trip_id = trip_id
    @name = stop['name']
    @coords = [stop['lat'], stop['lon']]
    @scheduled = stop['arrival'] / 1000
    @time = bus_arrival_time(stop) || @scheduled
    puts "scheduled #{Time.at @scheduled}, actual #{Time.at @time}, realtime #{@realtime}"
    @time_string = Time.at(@time).strftime("%-I:%M %P")
    @delta = delta(stop)
  end

  private
    def bus_arrival_time(stop)
      puts "0 s: getting real time arrival data"
      time = Time.now

      if Time.at(@scheduled) - Time.now < 45.minutes
        arrivals = all_arrivals(stop)
        puts "#{Time.now - time} s: got real time arrival data"
        if @route
          puts "!"*80, @route
          trip_by_route(arrivals)
        else
          trip_by_id(arrivals)
        end
      end
    end

    def trip_by_route(arrivals)
      candidates = arrivals.select { |arrival| arrival['routeShortName'] == @route }
      best = best_arrival(candidates)
      @trip_id = best['tripId']
      @realtime = best['predicted']
      realtime_arrival(best)
    end

    def trip_by_id(arrivals)
      arrival = arrivals.find { |arrival| arrival['tripId'] == @trip_id }
      if arrival
        @realtime = arrival['predicted']
        realtime_arrival(arrival)
      else
        @realtime = false
        @scheduled
      end
    end

    def best_arrival(candidates)
      earliest_time = @user_arrival_time + 3.minutes # BUG ALERT!

      candidates.sort_by! { |candidate| realtime_arrival(candidate) }
      candidates.find { |candidate| Time.at(realtime_arrival(candidate)) > earliest_time }
    end

    def all_arrivals(stop)
      stop_id = '1_' + stop['stopId']['id']
      url = "http://api.pugetsound.onebusaway.org/api/where/arrivals-and-departures-for-stop/#{stop_id}.json?key=#{ENV['OBA_KEY']}"
      HTTParty.get(url)['data']['entry']['arrivalsAndDepartures']
    end

    def delta(stop)
      delay = @time - stop['arrival'] / 1000
      if delay.abs < 60
        @realtime ? 'on time' : 'supposedly'
      elsif delay < 0
        "#{delay.abs / 60} minutes early"
      else
        "#{delay / 60} minutes late"
      end
    end

    def realtime_arrival(arrival)
      if arrival && arrival['predicted']
        arrival['predictedArrivalTime'] / 1000
      else
        @scheduled
      end
    end
end
