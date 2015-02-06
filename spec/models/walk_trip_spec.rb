require 'rails_helper'

RSpec.describe WalkTrip, :type => :model do
  before(:all) do
    @origin = [47.687161, -122.352952]
    @destination = [47.6069542, -122.3052976]
  end

  describe 'walk route' do
    before(:all) do
      VCR.use_cassette('walk_trip') do
        @route = WalkTrip.new(@origin, @destination).route
      end
    end

    it 'returns a single leg of walking directions' do
      expect(@route[:directions].length).to eq 1
      expect(@route[:directions][0].mode).to eq 'WALK'
    end
  end
end
