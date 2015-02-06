require 'rails_helper'

RSpec.describe TransitTrip, :type => :model do
  before(:all) do
    @origin = [47.687161, -122.352952]
    @destination = [47.6069542, -122.3052976]
  end

  describe 'transit route' do
    before(:all) do
      VCR.use_cassette('transit_trip') do
        @routes =	TransitTrip.new(@origin, @destination).routes
      end
    end

    it 'starts at my house' do
      expect(@routes[:from]).to eq "North 80th Street"
    end

    it 'ends at seven star' do
      expect(@routes[:to]).to eq "21st Avenue"
    end

    it 'returns an array of itineraries' do
      expect(@routes[:itineraries]).to be_instance_of Array
    end

    it 'returns an array of walking/bus/walking directions' do
      directions = @routes[:itineraries][0].route
      expect(directions[0]).to be_instance_of StreetLeg
      expect(directions[1]).to be_instance_of TransitLeg
      expect(directions[2]).to be_instance_of StreetLeg
    end
  end
end
