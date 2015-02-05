require 'rails_helper'

RSpec.describe Trip, :type => :model do

  def transit_trip
    HTTParty.get("http://localhost:8080/otp/routers/default/plan?fromPlace=47.687161,-122.352952&toPlace=47.6069542,-122.3052976").response.body
  end

  describe 'cassette', :vcr do
    it 'works' do
      puts transit_trip.class
      # expect(transit_trip).to exist
    end
  end
end
