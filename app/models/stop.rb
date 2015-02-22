require 'httparty'

class Stop
  attr_accessor :time, :trip_id

  def initialize(stop, user_arrival_time: nil, route: nil, xfer: false, continuation: false, trip_id: nil)
    @user_arrival_time = user_arrival_time
    @route = route
    @trip_id = trip_id

    Rails.logger.info @route ? "getting on #{@route} at #{Time.at @user_arrival_time}, xfer? #{xfer}, continuation? #{continuation}" : "getting stop by trip id #{@trip_id}"
    @name = stop['name']
    @coords = [stop['lat'], stop['lon']]
    @arrival_time = (xfer || continuation) ? next_scheduled_arrival(stop) : oba_time(stop) # WELL THAT'S WHERE THAT BUG IS FROM
    @delta = delta(stop)
  end

  private
    def oba_time(stop)
      time = Time.now
      scheduled = stop['arrival'] / 1000 # OTP times are in milliseconds
      if Time.at(scheduled) - Time.now < 45.minutes
        Rails.logger.info "0 s: getting real time data for #{@name}"
        arrivals = all_arrivals(stop)
        Rails.logger.info "#{Time.now - time} s: got real time arrival data"
        if @route
          trip_by_route(arrivals, stop)
        else
          @scheduled = scheduled
          trip_by_id(arrivals) || @scheduled
        end
      else
        @realtime = false
        @scheduled = scheduled
      end
    end

    def trip_by_route(arrivals, stop)
      candidates = arrivals.select { |arrival| arrival['routeShortName'] == @route }
      best = best_arrival(candidates)
      if best
        @trip_id = best['tripId']
        @realtime = best['predicted']
        @scheduled = best['scheduledArrivalTime'] / 1000
        realtime_arrival(best)
      else
        next_scheduled_arrival(stop)
      end
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
      @realtime = false
      time = Time.now
      url = "http://api.pugetsound.onebusaway.org/api/where/schedule-for-stop/#{stop_id(stop)}.json?key=#{ENV['OBA_KEY']}"

      Rails.logger.info "0 s: getting schedule for #{@name}}"
      stop_data = HTTParty.get(url)['data']
      Rails.logger.info "#{Time.now - time} s: got schedule"

      id = route_id(stop_data)
      route_schedule = route_stops(id)

      next_arrival = route_schedule.find { |stop| stop['arrivalTime']/1000 > @user_arrival_time + 3.minutes } # soonest viable (scheduled) arrival
      next_arrival['arrivalTime'] / 1000
    end

    def route_id(stop_data)
      stop_routes = stop_data['references']['routes'] # all routes that serve this stop
      route_reference = stop_routes.find { |route| route['shortName'] == @route } # reference info on route of interest
      route_reference['id'] # schedule can be found only by id
    end

    def route_stops(route_id)
      all_routes = stop_data['entry']['stopRouteSchedules'] # actual schedule data for all routes
      route_info = all_routes.find { |route| route['routeId'] == route_id } # schedule of route of interest
      route_stops = route_info['stopRouteDirectionSchedules'][0]['scheduleStopTimes'] # schedules are weirdly nested
      route_stops.sort_by { |stop| stop['arrivalTime'] }
    end

    def all_arrivals(stop)
      url = "http://api.pugetsound.onebusaway.org/api/where/arrivals-and-departures-for-stop/#{stop_id(stop)}.json?key=#{ENV['OBA_KEY']}"
      Rails.logger.info url
      HTTParty.get(url)['data']['entry']['arrivalsAndDepartures']
    end

    def delta(stop)
      Rails.logger.info Time.at(@arrival_time)
      Rails.logger.info Time.at(stop['arrival'] / 1000)
      delay = @arrival_time - stop['arrival'] / 1000
      delay_string = if delay.abs < 60
        @realtime ? 'on time' : 'supposedly'
      elsif delay < 0
        "#{delay.abs / 60} minutes early"
      else
        "#{delay / 60} minutes late"
      end
      Rails.logger.info delay_string
      delay_string
    end

    def realtime_arrival(arrival)
      if arrival && arrival['predicted']
        arrival['predictedArrivalTime'] / 1000
      else
        arrival['scheduledArrivalTime'] / 1000
      end
    end

    def stop_id(stop)
      Rails.env.production? ? stop['stopId'].gsub('ST:', '1_') : '1_' + stop['stopId']['id'] # I don't have the faintest idea why this is necessary
    end
end
