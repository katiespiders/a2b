require 'rails_helper'

RSpec.describe Trip, :type => :model do
  let(:origin) { [47.687161, -122.352952] }
  let(:destination) {  [47.6069542, -122.3052976] }

  describe 'initialize' do
    it 'generates a Trip object' do
      VCR.use_cassette('transit_trip') do
        trip = Trip.new('TRANSIT', origin, destination)
        expect(trip).to be_instance_of Trip
      end
    end
  end

  describe 'transit route' do
    it 'returns 3 bus trips from my house to seven star' do
      VCR.use_cassette('transit_trip') do
        routes = Trip.new('TRANSIT', origin, destination).routes
        expect(routes[:from]).to eq "North 80th Street"
        expect(routes[:to]).to eq "21st Avenue"
        expect(routes[:itineraries].length).to eq 3
      end
    end
  end

  describe 'car route' do
    it 'returns a hash with walking directions to car and driving directions to destination' do
      VCR.use_cassette('car_trip') do
        route = Trip.new('CAR', origin, destination).routes
        expect(route).to be_instance_of Hash
        expect(route[:itinerary][:directions][0].mode).to eq 'WALK'
        expect(route[:itinerary][:directions][1].mode).to eq 'CAR'
      end
    end
  end
end
