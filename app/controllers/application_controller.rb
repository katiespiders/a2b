require 'json'

class ApplicationController < ActionController::API
	before_filter :set_cors_headers

	def car_trip
		render json: CarTrip.new(params[:origin]).car
	end

	def walk_trip
		render json: WalkTrip.new(params[:origin], params[:destination]).trip
	end

	def transit_trips
		render json: TransitTrip.new(params[:origin], params[:destination]).trip
	end

	def all_trips
		origin, destination = params[:origin], params[:destination]
		render json: {
			car: CarTrip.new(origin, destination).trip,
			walk: WalkTrip.new(origin, destination).trip,
			transit: TransitTrip.new(origin, destination).trip
		}
	end

	private
		def set_cors_headers
			headers['Access-Control-Allow-Origin'] = '*'
			headers['Access-Control-Allow-Methods'] = 'GET'
		end

		def test
			{"car"=>{"address"=>"Western Ave 1465, 98101 Seattle", "coordinates"=>[47.60798, -122.34079], "exterior"=>true, "interior"=>false, "gas"=>100, "name"=>"ANK7400", "itinerary"=>{"from"=>"University Street", "to"=>"21st Avenue", "directions"=>[{"mode"=>"WALK", "start_time"=>1423525523000, "end_time"=>1423526118000, "turns"=>[{"street"=>"University Street", "abs_direction"=>"SOUTHWEST", "rel_direction"=>"depart", "distance"=>406.40537655987276}, {"street"=>"Harbor Steps", "abs_direction"=>"SOUTHWEST", "rel_direction"=>"CONTINUE", "distance"=>99.64780926145257}, {"street"=>"Post Alley", "abs_direction"=>"NORTHWEST", "rel_direction"=>"RIGHT", "distance"=>129.9022939060792}, {"street"=>"Union Street", "abs_direction"=>"SOUTHWEST", "rel_direction"=>"LEFT", "distance"=>47.6065532666801}, {"street"=>"Western Avenue", "abs_direction"=>"NORTHWEST", "rel_direction"=>"RIGHT", "distance"=>79.69356795568521}]}, {"mode"=>"CAR", "start_time"=>1423525523000, "end_time"=>1423526197000, "turns"=>[{"street"=>"Western Avenue", "abs_direction"=>"SOUTHEAST", "rel_direction"=>"depart", "distance"=>397.23313088417257}, {"street"=>"Spring Street", "abs_direction"=>"NORTHEAST", "rel_direction"=>"LEFT", "distance"=>195.36094410448356}, {"street"=>"2nd Avenue", "abs_direction"=>"SOUTHEAST", "rel_direction"=>"RIGHT", "distance"=>185.05735375147418}, {"street"=>"Marion Street", "abs_direction"=>"NORTHEAST", "rel_direction"=>"LEFT", "distance"=>379.69228387527676}, {"street"=>"6th Avenue", "abs_direction"=>"EAST", "rel_direction"=>"SLIGHTLY_RIGHT", "distance"=>196.24422007442791}, {"street"=>"Cherry Street", "abs_direction"=>"NORTHEAST", "rel_direction"=>"LEFT", "distance"=>487.5501933474529}, {"street"=>"Boren Avenue", "abs_direction"=>"SOUTHEAST", "rel_direction"=>"RIGHT", "distance"=>92.51167857275597}, {"street"=>"James Street", "abs_direction"=>"NORTHEAST", "rel_direction"=>"LEFT", "distance"=>155.1501335931771}, {"street"=>"East James Way", "abs_direction"=>"NORTHEAST", "rel_direction"=>"CONTINUE", "distance"=>226.6160455046888}, {"street"=>"East Cherry Street", "abs_direction"=>"EAST", "rel_direction"=>"CONTINUE", "distance"=>975.847365330962}, {"street"=>"21st Avenue", "abs_direction"=>"SOUTH", "rel_direction"=>"RIGHT", "distance"=>119.30650386053347}]}]}}, "walk"=>{"from"=>"University Street", "to"=>"21st Avenue", "time"=>2076, "directions"=>[{"mode"=>"WALK", "start_time"=>1423525521000, "end_time"=>1423527597000, "turns"=>[{"street"=>"University Street", "abs_direction"=>"NORTHEAST", "rel_direction"=>"depart", "distance"=>83.37618637838439}, {"street"=>"6th Avenue", "abs_direction"=>"SOUTHEAST", "rel_direction"=>"RIGHT", "distance"=>278.6503438810238}, {"street"=>"Madison Street", "abs_direction"=>"NORTHEAST", "rel_direction"=>"LEFT", "distance"=>97.51490052054184}, {"street"=>"7th Avenue", "abs_direction"=>"SOUTHEAST", "rel_direction"=>"RIGHT", "distance"=>92.88742460517884}, {"street"=>"Marion Street", "abs_direction"=>"NORTHEAST", "rel_direction"=>"LEFT", "distance"=>385.907992131864}, {"street"=>"Boren Avenue", "abs_direction"=>"SOUTHEAST", "rel_direction"=>"RIGHT", "distance"=>371.14816455740583}, {"street"=>"Jefferson Street", "abs_direction"=>"NORTHEAST", "rel_direction"=>"LEFT", "distance"=>94.02370207647076}, {"street"=>"East Jefferson Street", "abs_direction"=>"EAST", "rel_direction"=>"SLIGHTLY_RIGHT", "distance"=>1179.697149567942}, {"street"=>"21st Avenue", "abs_direction"=>"NORTH", "rel_direction"=>"LEFT", "distance"=>86.64163651862239}]}]}, "transit"=>{"from"=>"University Street", "to"=>"21st Avenue", "itineraries"=>[{"start_time"=>1423525899000, "end_time"=>1423527330000, "walk_time"=>251, "transit_time"=>1178, "wait_time"=>2, "walk_distance"=>314.38667891649766, "xfers"=>0, "fare"=>250, "route"=>[{"mode"=>"WALK", "start_time"=>1423525899000, "end_time"=>1423526120000, "turns"=>[{"street"=>"University Street", "abs_direction"=>"SOUTHWEST", "rel_direction"=>"depart", "distance"=>209.4202847758324}, {"street"=>"3rd Avenue", "abs_direction"=>"NORTHWEST", "rel_direction"=>"RIGHT", "distance"=>71.99967911133803}]}, {"mode"=>"BUS", "route"=>"3", "headsign"=>"MADRONA AND 34TH AVE, VIA E CHERRY ST", "agency"=>"KCM", "trip_id"=>"1_18151797", "continuation"=>false, "express"=>false, "stops"=>[{"name"=>"3RD AVE & UNION ST", "stop_id"=>"1_450", "trip_id"=>"1_18151797", "scheduled"=>1423526120000, "real_time"=>true, "actual"=>1423526115000}, {"name"=>"21ST AVE & E JAMES ST", "stop_id"=>"1_13001", "trip_id"=>"1_18151797", "scheduled"=>1423527299000, "real_time"=>true, "actual"=>1423527293000}]}, {"mode"=>"WALK", "start_time"=>1423527300000, "end_time"=>1423527330000, "turns"=>[{"street"=>"East James Street", "abs_direction"=>"WEST", "rel_direction"=>"depart", "distance"=>8.367458313123665}, {"street"=>"21st Avenue", "abs_direction"=>"SOUTH", "rel_direction"=>"LEFT", "distance"=>24.531587545454656}]}]}, {"start_time"=>1423526013000, "end_time"=>1423527568000, "walk_time"=>886, "transit_time"=>667, "wait_time"=>2, "walk_distance"=>1134.658015400311, "xfers"=>0, "route"=>[{"mode"=>"WALK", "start_time"=>1423526013000, "end_time"=>1423526300000, "turns"=>[{"street"=>"University Street", "abs_direction"=>"NORTHEAST", "rel_direction"=>"depart", "distance"=>83.37618637838439}, {"street"=>"6th Avenue", "abs_direction"=>"SOUTHEAST", "rel_direction"=>"RIGHT", "distance"=>92.78591962803901}, {"street"=>"Seneca Street", "abs_direction"=>"NORTHEAST", "rel_direction"=>"LEFT", "distance"=>186.57687646733598}]}, {"mode"=>"BUS", "route"=>"2", "headsign"=>"DOWNTOWN SEATTLE", "agency"=>"KCM", "trip_id"=>"1_25938091", "continuation"=>false, "express"=>false, "stops"=>[{"name"=>"SENECA ST & 8TH AVE", "stop_id"=>"1_3150", "trip_id"=>"1_25938091", "scheduled"=>1423526300000, "real_time"=>true, "actual"=>1423526512000}, {"name"=>"E UNION ST & 20TH AVE", "stop_id"=>"1_3200", "trip_id"=>"1_25938091", "scheduled"=>1423526968000, "real_time"=>true, "actual"=>1423527178000}]}, {"mode"=>"WALK", "start_time"=>1423526969000, "end_time"=>1423527568000, "turns"=>[{"street"=>"East Union Street", "abs_direction"=>"EAST", "rel_direction"=>"depart", "distance"=>10.358360885820126}, {"street"=>"20th Avenue", "abs_direction"=>"SOUTH", "rel_direction"=>"RIGHT", "distance"=>639.3205521168688}, {"street"=>"East James Street", "abs_direction"=>"EAST", "rel_direction"=>"LEFT", "distance"=>97.5344722336483}, {"street"=>"21st Avenue", "abs_direction"=>"SOUTH", "rel_direction"=>"RIGHT", "distance"=>24.531587545454656}]}]}, {"start_time"=>1423526383000, "end_time"=>1423527888000, "walk_time"=>343, "transit_time"=>1160, "wait_time"=>2, "walk_distance"=>435.3342330160233, "xfers"=>0, "fare"=>250, "route"=>[{"mode"=>"WALK", "start_time"=>1423526383000, "end_time"=>1423526604000, "turns"=>[{"street"=>"University Street", "abs_direction"=>"SOUTHWEST", "rel_direction"=>"depart", "distance"=>209.4202847758324}, {"street"=>"3rd Avenue", "abs_direction"=>"NORTHWEST", "rel_direction"=>"RIGHT", "distance"=>71.99967911133803}]}, {"mode"=>"BUS", "route"=>"4", "headsign"=>"JUDKINS PARK, VIA 23RD AVE", "agency"=>"KCM", "trip_id"=>"1_18151593", "continuation"=>false, "express"=>false, "stops"=>[{"name"=>"3RD AVE & UNION ST", "stop_id"=>"1_450", "trip_id"=>"1_18151593", "scheduled"=>1423526604000, "real_time"=>false, "actual"=>1423526604000}, {"name"=>"E JEFFERSON ST & 20TH AVE", "stop_id"=>"1_12991", "trip_id"=>"1_18151593", "scheduled"=>1423527765000, "real_time"=>false, "actual"=>1423527765000}]}, {"mode"=>"WALK", "start_time"=>1423527766000, "end_time"=>1423527888000, "turns"=>[{"street"=>"East Jefferson Street", "abs_direction"=>"EAST", "rel_direction"=>"depart", "distance"=>67.20496343948165}, {"street"=>"21st Avenue", "abs_direction"=>"NORTH", "rel_direction"=>"LEFT", "distance"=>86.64163651862239}]}]}, {"start_time"=>1423526863000, "end_time"=>1423528290000, "walk_time"=>251, "transit_time"=>1174, "wait_time"=>2, "walk_distance"=>314.38667891649766, "xfers"=>0, "fare"=>250, "route"=>[{"mode"=>"WALK", "start_time"=>1423526863000, "end_time"=>1423527084000, "turns"=>[{"street"=>"University Street", "abs_direction"=>"SOUTHWEST", "rel_direction"=>"depart", "distance"=>209.4202847758324}, {"street"=>"3rd Avenue", "abs_direction"=>"NORTHWEST", "rel_direction"=>"RIGHT", "distance"=>71.99967911133803}]}, {"mode"=>"BUS", "route"=>"3", "headsign"=>"DOWNTOWN SEATTLE", "agency"=>"KCM", "trip_id"=>"1_18151594", "continuation"=>false, "express"=>false, "stops"=>[{"name"=>"3RD AVE & UNION ST", "stop_id"=>"1_450", "trip_id"=>"1_18151594", "scheduled"=>1423527084000, "real_time"=>true, "actual"=>1423527085000}, {"name"=>"21ST AVE & E JAMES ST", "stop_id"=>"1_13001", "trip_id"=>"1_18151594", "scheduled"=>1423528259000, "real_time"=>false, "actual"=>1423528259000}]}, {"mode"=>"WALK", "start_time"=>1423528260000, "end_time"=>1423528290000, "turns"=>[{"street"=>"East James Street", "abs_direction"=>"WEST", "rel_direction"=>"depart", "distance"=>8.367458313123665}, {"street"=>"21st Avenue", "abs_direction"=>"SOUTH", "rel_direction"=>"LEFT", "distance"=>24.531587545454656}]}]}]}}

		end
end
