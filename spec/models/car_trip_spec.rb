require 'rails_helper'
require 'latitude'
require 'location'

RSpec.describe CarTrip, :type => :model do
  before(:all) do
    @origin = "1301 5th Ave Seattle"
    @destination = "525 21st Ave Seattle"
  end

  describe 'car route' do
    before(:all) do
      VCR.use_cassette('car_trip') do
        @route = CarTrip.new(@origin, @destination).route
        @coords = @route[:coordinates]
        @itinerary = @route[:itinerary]
        @directions = @itinerary[:directions]
      end
    end

    it 'finds a car within 1.6 km' do
      distance = Latitude.great_circle_distance(@origin.lat, @origin.long, @coords.lat, @coords.long)
      expect(distance).to be < 1.6
    end

    it 'returns walking directions for first leg' do
      expect(@directions[0].mode).to eq 'WALK'
    end

    it 'returns driving directions for second leg' do
      expect(@directions[1].mode).to eq 'CAR'
    end
  end
end
