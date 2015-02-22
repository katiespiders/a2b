require 'httparty'

class Stop
  attr_accessor :arrival_time, :trip_id

  def initialize(stop, user_arrival_time: nil, route: nil, get_oba: false)
    @name = stop['name']
    @coords = [stop['lat'], stop['lon']]

    if route
      @route = route
      @earliest_time = user_arrival_time + 3.minutes

      time = Time.now
      Rails.logger.info "0 s: finding the first #{@route} at #{@name} after #{Time.at(@earliest_time)}"

      @arrival_time = get_oba ? oba_time(stop) : next_scheduled_time(stop)
      @delta = delta(stop)

      Rails.logger.info "#{Time.now - time} s: found bus at #{Time.at(@arrival_time)} #{@delta}"
    end
  end

  private
    def oba_time(stop)
      arrivals = all_arrivals(stop)
      trip_by_route(arrivals, stop)
    end

    def all_arrivals(stop)
      url = "http://api.pugetsound.onebusaway.org/api/where/arrivals-and-departures-for-stop/#{stop_id(stop)}.json?key=#{ENV['OBA_KEY']}"
      HTTParty.get(url)['data']['entry']['arrivalsAndDepartures']
    end

    def trip_by_route(arrivals, stop)
      candidates = arrivals.select { |arrival| arrival['routeShortName'] == @route }
      best = best_arrival(candidates)
      if best
        @trip_id = best['tripId']
        @realtime = best['predicted']
        @scheduled_time = best['scheduledArrivalTime'] / 1000 # milliseconds
        realtime_arrival(best)
      else
        next_scheduled_time(stop)
      end
    end

    def best_arrival(candidates)
      candidates.sort_by! { |candidate| realtime_arrival(candidate) }
      candidates.find { |candidate| realtime_arrival(candidate) > @earliest_time }
    end

    def realtime_arrival(arrival)
      if arrival && arrival['predicted']
        arrival['predictedArrivalTime'] / 1000
      else
        arrival['scheduledArrivalTime'] / 1000
      end
    end

    # Gets arrival times by schedule instead of by real-time, ostensibly to reduce API calls, but currently just calls a different method in the same API. Will serve its actual purpose when I figure out how to parse this out of the GTFS.
    def next_scheduled_time(stop)
      @realtime = false
      stop_data = stop_schedule(stop)
      route_schedule = route_stops(stop_data)
      next_arrival = route_schedule.find { |stop| stop['arrivalTime']/1000 > @earliest_time } # soonest viable (scheduled) arrival
      next_arrival ||= route_schedule[0] # if none before midnight, gets first arrival of the day; bug when actual next day's schedule is different.
      @scheduled_time = next_arrival['arrivalTime'] / 1000
    end

    def stop_schedule(stop)
      time = Time.now
      url = "http://api.pugetsound.onebusaway.org/api/where/schedule-for-stop/#{stop_id(stop)}.json?key=#{ENV['OBA_KEY']}"

      Rails.logger.info "0 s: getting schedule for #{@name}"
      stop_data = HTTParty.get(url)['data']
      Rails.logger.info "#{Time.now - time} s: got schedule"
      stop_data
    end

    def route_stops(stop_data)
      all_routes = stop_data['entry']['stopRouteSchedules']
      route_info = all_routes.find { |route| route['routeId'] == route_id(stop_data) }
      route_stops = route_info['stopRouteDirectionSchedules'][0]['scheduleStopTimes']
      route_stops.sort_by { |stop| stop['arrivalTime'] }
    end

    def route_id(stop_data)
      stop_routes = stop_data['references']['routes']
      route_reference = stop_routes.find { |route| route['shortName'] == @route.sub(/(\d+)[E]/, '\1') } # route names here do not include E for express
      route_reference['id'] # schedule can be found only by id
    end

    def delta(stop)
      delay = @arrival_time - @scheduled_time
      delay_string = if delay.abs < 60
        @realtime ? 'on time' : 'supposedly'
      elsif delay < 0
        "#{delay.abs / 60} minutes early"
      else
        "#{delay / 60} minutes late"
      end

      "(#{delay_string})"
    end

    def stop_id(stop)
      Rails.env.production? ? stop['stopId'].gsub('ST:', '1_') : '1_' + stop['stopId']['id'] # I don't have the faintest idea why this is necessary
    end
end
