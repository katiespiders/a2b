require 'rails_helper'

describe 'transit trip' do
  before(:all) do
    VCR.use_cassette('transit trip Greenwood-Capitol Hill') do
      origin = '47.677798,-122.396372'
      destination = '47.687187,-122.352988'
      @trip = Trip.new(origin, destination)
      @legs = @trip.legs
      @summary = @trip.summary
      @legs.each_with_index do |leg, i|
        puts "leg #{i} (#{leg.mode}): #{Time.at(leg.start_time)} to #{Time.at(leg.end_time)} (#{leg.duration/60} minutes)"
      end
    end
  end

  it 'returns an array of trip legs' do
    expect(@legs).to be_instance_of Array
    expect(@legs[0]).to be_instance_of Leg
  end

  it 'flags all transit legs but the first as transfers' do
    transit_legs = @legs.select { |leg| leg.mode != 'WALK' }
    expect(transit_legs[0].xfer).to be false
    xfers = transit_legs.select { |leg| leg.xfer == true }
    expect(xfers.length).to eq transit_legs.length - 1
  end

  it 'calculates total walking time' do
    expect(@summary[:walk_time]).to eq 1132
  end

  it 'calculates total transit time' do
    expect(@summary[:transit_time]).to eq 699
  end

  it 'calculates total wait time' do
    expect(@summary[:wait_time]).to eq 924
  end
end
