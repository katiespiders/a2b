require 'rails_helper'
# REWRITE THESE WITH FACTORY_GIRL. DON'T USE VCR THIS ISN'T WHAT IT'S FOR

RSpec.describe Turn, :type => :model do
	describe 'to_s' do
		it 'provides directions for first leg' do
			VCR.use_cassette('departure') do
				step = {
					'streetName' => 'North 80th Street',
					'absoluteDirection' => 'EAST',
					'relativeDirection' => 'DEPART',
					'distance' => 500
				}

				t = Turn.new(step)
				response = "Go EAST on North 80th Street for 500 meters.\n"
				expect(t.to_s).to eq response
			end
		end

		it 'provides directions for a turn' do
			VCR.use_cassette('turn') do
				step = {
					'streetName' => 'Fremont Avenue North',
					'absoluteDirection' => 'NORTH',
					'relativeDirection' => 'LEFT',
					'distance' => 500
				}

				t = Turn.new(step)
				response = "Turn LEFT to go NORTH on Fremont Avenue North for 500 meters.\n"
				expect(t.to_s).to eq response
			end
		end

		it 'provides directions for a continuation' do
			VCR.use_cassette('continuation') do
				step = {
					'streetName' => 'Northwest 85th Street',
					'absoluteDirection' => 'WEST',
					'relativeDirection' => 'CONTINUE',
					'distance' => 500
				}

				t = Turn.new(step)
				response = "Continue WEST on Northwest 85th Street for 500 meters.\n"
				expect(t.to_s).to eq response
			end
		end
	end	
end
