require 'httparty'

class Stop
  attr_accessor :time, :trip_id

  def initialize(stop, user_arrival_time: nil, route: nil, xfer: false, continuation: false, trip_id: nil)
    @user_arrival_time = user_arrival_time
    @route = route
    @trip_id = trip_id
    logger.debug @route ? "getting on #{@route} at #{Time.at @user_arrival_time}, xfer? #{xfer}, continuation? #{continuation}" : "getting stop by trip id #{@trip_id}"
    @name = stop['name']
    @coords = [stop['lat'], stop['lon']]
    @time = (xfer || continuation) ? next_scheduled_arrival(stop) : bus_arrival_time(stop)
    @delta = delta(stop)
  end

  private
    def bus_arrival_time(stop)
      time = Time.now
      scheduled = stop['arrival'] / 1000
      if Time.at(scheduled) - Time.now < 45.minutes
        arrivals = all_arrivals(stop)
        logger.debug "#{Time.now - time} s: got real time arrival data"
        if @route
          trip_by_route(arrivals)
        else
          @scheduled = scheduled
          trip_by_id(arrivals) || @scheduled
        end
      else
        @realtime = false
        @scheduled = scheduled
      end
    end

    def trip_by_route(arrivals)
      candidates = arrivals.select { |arrival| arrival['routeShortName'] == @route }
      best = best_arrival(candidates)
      @trip_id = best['tripId']
      @realtime = best['predicted']
      @scheduled = best['scheduledArrivalTime'] / 1000
      realtime_arrival(best)
    end

    def trip_by_id(arrivals)
      arrival = arrivals.find { |arrival| arrival['tripId'] == @trip_id }
      if arrival
        @realtime = arrival['predicted']
        realtime_arrival(arrival)
      else
        @realtime = false
      end
    end

    def best_arrival(candidates)
      candidates.sort_by! { |candidate| realtime_arrival(candidate) }
      candidates.find { |candidate| realtime_arrival(candidate) > @user_arrival_time + 3.minutes }
    end

    def next_scheduled_arrival(stop)
      stop_id = '1_' + stop['stopId']['id']
      url = "http://api.pugetsound.onebusaway.org/api/where/schedule-for-stop/#{stop_id}.json?key=#{ENV['OBA_KEY']}"
      stop_data = HTTParty.get(url)['data']
      stop_routes = stop_data['references']['routes']
      route_reference = stop_routes.find { |route| route['shortName'] == @route }
      route_id = route_reference['id']
      all_routes = stop_data['entry']['stopRouteSchedules']
      route_info = all_routes.find { |route| route['routeId'] == route_id }
      route_stops = route_info['stopRouteDirectionSchedules'][0]['scheduleStopTimes']
      route_stops.sort_by! { |stop| stop['arrivalTime'] }
      r = route_stops.find { |stop| stop['arrivalTime']/1000 > @user_arrival_time + 3.minutes }
      r['arrivalTime'] / 1000
    end

    def all_arrivals(stop)
      stop_id = '1_' + stop['stopId']['id']
      url = "http://api.pugetsound.onebusaway.org/api/where/arrivals-and-departures-for-stop/#{stop_id}.json?key=#{ENV['OBA_KEY']}"
      HTTParty.get(url)['data']['entry']['arrivalsAndDepartures']
    end

    def delta(stop)
      logger.debug "s"*80, stop
      delay = @time - stop['arrival'] / 1000
      d = if delay.abs < 60
        @realtime ? 'on time' : 'supposedly'
      elsif delay < 0
        "#{delay.abs / 60} minutes early"
      else
        "#{delay / 60} minutes late"
      end
      logger.debug "d"*80, d
      d

    end

    def realtime_arrival(arrival)
      if arrival && arrival['predicted']
        arrival['predictedArrivalTime'] / 1000
      else
        arrival['scheduledArrivalTime'] / 1000
      end
    end
end
