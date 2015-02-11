require 'rails_helper'

RSpec.describe TransitTrip, :type => :model do
  before(:all) do
    VCR.use_cassette('test transit trip') do
      @origin = "1301 5th Ave Seattle"
      @destination = "525 21st Ave Seattle"
    end
  end

  describe 'transit route' do
    before(:all) do
      VCR.use_cassette('transit trip') do
        @trip =	TransitTrip.new(@origin, @destination).trip
      end
    end

    it 'starts at Rainier Tower' do
      expect(@trip[:from]).to eq "5th Avenue"
    end

    it 'ends at Seven Star' do
      expect(@trip[:to]).to eq "21st Avenue"
    end

    it 'returns an array of itineraries' do
      expect(@trip[:directions]).to be_instance_of Array
    end

    it 'returns an array of walking/bus/walking directions' do
      directions = @trip[:directions][0].trips
      expect(directions[0]).to be_instance_of StreetLeg
      expect(directions[1]).to be_instance_of TransitLeg
      expect(directions[2]).to be_instance_of StreetLeg
    end
  end
end
