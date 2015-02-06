require 'rails_helper'

RSpec.describe Trip, :type => :model do
	before(:all) do
		@origin = [47.687161, -122.352952]
		@destination = [47.6069542, -122.3052976]
	end

  describe 'initialize' do
    it 'generates a Trip object' do
      VCR.use_cassette('transit_trip') do
        trip = Trip.new('TRANSIT', @origin, @destination)
        expect(trip).to be_instance_of Trip
      end
    end
  end

  describe 'transit route' do
		before(:all) do
			VCR.use_cassette('transit_trip') do
				@routes =	Trip.new('TRANSIT', @origin, @destination).itinerary
			end
		end

    it 'starts at my house' do
			expect(@routes[:from]).to eq "North 80th Street"
		end

		it 'ends at seven star' do
			expect(@routes[:to]).to eq "21st Avenue"
		end

		it 'returns 3 itineraries' do
			expect(@routes[:itineraries].length).to eq 3
		end

		it 'returns an array of walking/bus/walking directions' do
			directions = @routes[:itineraries][0][:directions]
			expect(directions[0]).to be_instance_of StreetLeg
			expect(directions[1]).to be_instance_of TransitLeg
			expect(directions[2]).to be_instance_of StreetLeg
    end
  end

  describe 'car route' do
		before(:all) do
      VCR.use_cassette('car_trip') do
        @route = Trip.new('CAR', @origin, @destination).itinerary
				@coords = @route[:coordinates]
				@itinerary = @route[:itinerary]
				@directions = @itinerary[:directions]
			end
		end

    it 'finds the nearest car' do
			expect(@coords).to eq [47.69969, -122.3558]
		end

		it 'returns walking directions for first leg' do
		 	expect(@route[:itinerary][:directions][0].mode).to eq 'WALK'
		end

		it 'returns driving directions for second leg' do
		 	expect(@route[:itinerary][:directions][1].mode).to eq 'CAR'
		end
	end

	describe 'walk route' do
		before(:all) do
			VCR.use_cassette('walk_trip') do
				@route = Trip.new('WALK', @origin, @destination).itinerary
			end
		end

		it 'returns a single leg of walking directions' do
			expect(@route[:directions].length).to eq 1
			expect(@route[:directions][0].mode).to eq 'WALK'
		end
	end
end
