require 'rails_helper'

RSpec.describe CarTrip, :type => :model do
  before(:all) do
    @origin = [47.687161, -122.352952]
    @destination = [47.6069542, -122.3052976]
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

    it 'finds the nearest car' do
      expect(@coords).to eq [47.68399, -122.35496]
    end

    it 'returns walking directions for first leg' do
       expect(@route[:itinerary][:directions][0].mode).to eq 'WALK'
    end

    it 'returns driving directions for second leg' do
       expect(@route[:itinerary][:directions][1].mode).to eq 'CAR'
    end
  end
end
