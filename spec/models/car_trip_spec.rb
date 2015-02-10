require 'rails_helper'
require 'latitude'
require 'location'

RSpec.describe CarTrip, :type => :model do
  before(:all) do
    VCR.use_cassette('test trip') do
      origin = "1301 5th Ave Seattle"
      destination = "525 21st Ave Seattle"
      @trip = CarTrip.new(origin, destination)
    end
  end

  describe 'car route' do
    before(:all) do
      VCR.use_cassette('car trip') do
        @route = @trip.route
        @coords = @route[:coordinates]
        @itinerary = @route[:itinerary]
      end
    end

    it 'returns walking directions for first leg' do
      expect(@itinerary[0][0].mode).to eq 'WALK'
    end

    it 'returns driving directions for second leg' do
      expect(@itinerary[1][0].mode).to eq 'CAR'
    end
  end
end
